//
//  Model+Statement.swift
//  ForaBank
//
//  Created by Дмитрий on 12.04.2022.
//

import Foundation
import ServerAgent

typealias StatementsData = [ProductData.ID: ProductStatementsStorage]

//MARK: - Action

extension ModelAction {
    
    enum Statement {
        
        enum List {
            
            struct Request: Action {
                
                let productId: ProductData.ID
                let direction: Period.Direction
                let category: [String]?
            }
        }
    }
}

//MARK: - Helpers

extension Model {
    
    static let statementsSerial = "version 3"
    var statementsRequestDays: Int { 30 }
    var statementslatestDaysOffset: Int { 7 }
    
    func statement(statementId: ProductStatementData.ID) -> ProductStatementData? {
        
        statements.value.values.flatMap({ $0.statements }).first(where: { $0.id == statementId })
    }
    
    func product(statementId: ProductStatementData.ID) -> ProductData? {
        
        let statements = statements.value
        
        for productId in statements.keys {
            
            guard let storage = statements[productId] else {
                continue
            }
            
            if storage.statements.contains(where: { $0.id == statementId }) {
                
                return product(productId: productId)
            }
        }
        
        return nil
    }
}

//MARK: - Handlers

extension Model {

    func handleStatementRequest(_ payload: ModelAction.Statement.List.Request) {
        
        // check if statemensts for this product alredy updating
        guard statementsIsUpdating(for: payload.productId) == false else {
            return
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard let product = products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId }) else {
            return
        }
        
        Task {
            
            statementsUpdating.value[product.id] = .downloading(payload.direction)
            var storage = statements.value[product.id]
            
            do {

                var continueRequests = true
                var currentDirection = payload.direction
                let currentDate = Date()
  
                repeat {
                    
                    guard let requestProperties = Self.statementsRequestParameters(
                        storage: storage,
                        product: product,
                        direction: currentDirection,
                        days: statementsRequestDays,
                        currentDate: currentDate,
                        latestDaysOffset: statementslatestDaysOffset
                    ) else {
                        break
                    }

                    let resultStatements = try await statementsFetch(
                        token: token,
                        product: product,
                        period: requestProperties.period,
                        operationType: requestProperties.operationType?.map({ 
                            .init(rawValue: $0.rawValue) ?? .credit
                        }),
                        operationGroup: payload.category?.map({ .init(rawValue: $0) ?? .aviaTickets} )
//                            requestProperties.operationGroup?.map({
//                            .init(rawValue: $0.rawValue) ?? .aviaTickets
//                        })
                    )
                    statementsCheckDuplicates(product: product, statements: resultStatements)
     
                    switch currentDirection {
                    case .latest:
                        // check if it was first statements request and nothing found
                        if storage == nil, resultStatements.isEmpty {
                            
                            // swich direction to history
                            currentDirection = .eldest
                        }
                        
                    case .eldest:
                        // chack if we found some statements
                        if resultStatements.isEmpty == false {
                            
                            // stop requesting eldest periods
                            continueRequests = false
                        }
                    case let .custom(start: startDate, end: endDate):
                        continueRequests = false
                    }

                    let update = ProductStatementsStorage.Update(
                        period: requestProperties.period,
                        statements: resultStatements,
                        direction: requestProperties.direction,
                        limitDate: requestProperties.limitDate
                    )

                    storage = Self.reduce(storage: storage, update: update, product: product)

                } while continueRequests
                
                statementsUpdating.value[product.id] = .idle
                
            } catch {

                LoggerAgent.shared.log(level: .error, category: .model, message: "Failed downloading statements for productId: \(payload.productId) direction: \(payload.direction), with error: \(error)")
                statementsUpdating.value[product.id] = .failed
            }
            
            self.statements.value[product.id] = storage

            do {
                
                try self.localAgent.store(self.statements.value, serial: Self.statementsSerial)
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .model, message: "Failed caching statements with error: \(error.localizedDescription)")
            }
        }
    }
    
    func statementsFetch(
        token: String,
        product: ProductData,
        period: Period,
        operationType: [Services.CardStatementForPeriodPayload.OperationType]?,
        operationGroup: [Services.CardStatementForPeriodPayload.OperationGroup]?
    ) async throws -> [ProductStatementData] {
        
        switch product.productType {
        case .card:
            
            return try await Services.makeCardStatementForPeriod(
                httpClient: self.authenticatedHTTPClient(), 
                productId: product.id,
                period: period,
                operationType: operationType,
                operationGroup: operationGroup
            )
            
        case .account:
            let command = ServerCommands.AccountController.GetAccountStatementForPeriod(token: token, productId: product.id, period: period)
            
            return try await accountStatementsFetch(command: command)
            
        case .deposit:
            let command = ServerCommands.DepositController.GetDepositStatementForPeriod(token: token, productId: product.id, period: period)
            
            return try await depositStatementsFetch(command: command)
            
        case .loan:
            throw ModelStatementsError.unsupportedProductType(.loan)
        }
    }
    
    func accountStatementsFetch(command: ServerCommands.AccountController.GetAccountStatementForPeriod) async throws -> [ProductStatementData] {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let data = response.data else {
                            continuation.resume(with: .failure(ModelProductsError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: data.operationList)

                    default:
                        continuation.resume(with: .failure(ModelProductsError.statusError(status: response.statusCode, message: response.errorMessage)))
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(ModelProductsError.serverCommandError(error: error.localizedDescription)))
                }
            }
        }
    }
    
    func depositStatementsFetch(command: ServerCommands.DepositController.GetDepositStatementForPeriod) async throws -> [ProductStatementData] {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let data = response.data else {
                            continuation.resume(with: .failure(ModelProductsError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: data.operationList)

                    default:
                        continuation.resume(with: .failure(ModelProductsError.statusError(status: response.statusCode, message: response.errorMessage)))
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(ModelProductsError.serverCommandError(error: error.localizedDescription)))
                }
            }
        }
    }
}

//MARK: - Statements Updates

extension Model {
    
    func statementsIsUpdating(for productId: ProductData.ID ) -> Bool {
        
        guard let state = statementsUpdating.value[productId] else {
            return false
        }
        
        return state.isDownloadActive
    }
    
    static func statementsRequestParameters(
        storage: ProductStatementsStorage?,
        product: ProductData,
        direction: Period.Direction,
        days: Int,
        currentDate: Date,
        latestDaysOffset: Int
    ) -> ProductStatementsStorage.Request? {
        
        switch direction {
        case .latest:
            if let storage = storage {
                
                guard let period = storage.latestPeriod(days: days, limitDate: currentDate) else {
                   return nil
                }
                
                if period.end < currentDate {
                    
                    return .init(
                        period: period,
                        direction: direction,
                        limitDate: currentDate,
                        operationType: nil,
                        operationGroup: nil
                    )
                    
                } else {
                    
                    let startDate = period.start.advanced(by: -TimeInterval.value(days: latestDaysOffset))
                    let endDate = period.end
                    
                    let adjustedPeriod = Period(start: startDate, end: endDate)
                    
                    return .init(
                        period: adjustedPeriod,
                        direction: direction,
                        limitDate: currentDate,
                        operationType: nil,
                        operationGroup: nil
                    )
                }
                
            } else {
                
                let period = Period(daysBack: days, from: currentDate)
                return .init(
                    period: period,
                    direction: direction,
                    limitDate: currentDate,
                    operationType: nil,
                    operationGroup: nil
                )
            }
            
        case .eldest:
            guard let storage = storage,
                  let limitDate = ProductStatementsStorage.historyLimitDate(for: product),
                  let period = storage.eldestPeriod(days: days, limitDate: limitDate) else { return nil }
            
            return .init(
                period: period,
                direction: direction,
                limitDate: limitDate,
                operationType: nil,
                operationGroup: nil
            )
        
        case let .custom(start: startDate, end: endDate):
            let adjustedPeriod = Period(start: startDate, end: endDate)
            return .init(
                period: adjustedPeriod,
                direction: direction,
                limitDate: currentDate,
                operationType: nil,
                operationGroup: nil
            )
        }
    }
}

//MARK: - Reducers

extension Model {
    
    static func reduce(storage: ProductStatementsStorage?, update: ProductStatementsStorage.Update, product: ProductData ) -> ProductStatementsStorage {
        
        let historyLimitDate = ProductStatementsStorage.historyLimitDate(for: product)
        if let storage = storage {
            
            return storage.updated(with: update, historyLimitDate: historyLimitDate)
            
        } else {
            
            return ProductStatementsStorage(with: update, historyLimitDate: historyLimitDate)
        }
    }
}

//MARK: - Reducers

extension Model {
    
    func statementsCheckDuplicates(product: ProductData, statements: [ProductStatementData]) {
        
        let statementsIds = statements.map{ $0.id }
        let uniqueStatementsIds = Set(statementsIds)
        
        guard statementsIds.count != uniqueStatementsIds.count else {
            return
        }
        
        let duplicates = uniqueStatementsIds.filter { uniqueStatementId in
            
            statementsIds.filter({ $0 == uniqueStatementId }).count > 1
        }
        
        LoggerAgent.shared.log(level: .error, category: .model, message: "Detected statements duplicates: \(duplicates) for product type: \(product.productType) with id: \(product.id)")
    }
    
}

//MARK: - Error

enum ModelStatementsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: Error)
    case unsupportedProductType(ProductType)
}
