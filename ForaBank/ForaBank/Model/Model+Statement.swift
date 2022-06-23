//
//  Model+Statement.swift
//  ForaBank
//
//  Created by Дмитрий on 12.04.2022.
//

import Foundation

typealias StatementsData = [ProductData.ID: ProductStatementsStorage]

//MARK: - Action

extension ModelAction {
    
    enum Statement {
        
        enum List {
            
            struct Request: Action {
                
                let productId: ProductData.ID
                let direction: Period.Direction
            }
            
            struct Response: Action {
                
                let result: Result<[ProductStatementData], Error>
            }
        }
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
        
        guard let product = products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId }),
              let requestProperties = statementsRequestParameters(for: product, direction: payload.direction) else {
            return
        }
        
        statementsUpdating.value[payload.productId] = .downloading(payload.direction)

        switch product.productType {
        case .card:
            let command = ServerCommands.CardController.GetCardStatementForPeriod(token: token, productId: payload.productId, period: requestProperties.period)
            executeCommand(command: command, product: product)
            
        case .account:
            let command = ServerCommands.AccountController.GetAccountStatementForPeriod(token: token, productId: payload.productId, period: requestProperties.period)
            executeCommand(command: command, product: product)
            
        case .deposit:
            let command = ServerCommands.DepositController.GetDepositStatementForPeriod(token: token, productId: payload.productId, period: requestProperties.period)
            executeCommand(command: command, product: product)
            
        case .loan:
            statementsUpdating.value[payload.productId] = .idle
            return
        }
        
        func executeCommand<Command: ServerCommand>(command: Command, product: ProductData) {
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        self.statementsUpdating.value[product.id] = .idle
                        
                        guard let statementsList = response.data as? [ProductStatementData] else {
                            
                            self.action.send(ModelAction.Statement.List.Response(result: .failure(ModelStatementsError.emptyData(message: response.errorMessage))))
     
                            return
                        }
                        
                        let update = ProductStatementsStorage.Update(period: requestProperties.period, statements: statementsList, direction: requestProperties.direction, limitDate: requestProperties.limitDate)
                        
                        self.statements.value = Self.reduce(statements: self.statements.value , with: update, for: product)

                        do {
                            
                            try self.localAgent.store(self.statements.value, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                        
                        self.action.send(ModelAction.Statement.List.Response(result: .success(statementsList)))
                        
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Statement.List.Response(result: .failure(ModelStatementsError.statusError(status: response.statusCode, message: response.errorMessage))))
                        self.statementsUpdating.value[product.id] = .failed
                    }
                    
                case .failure(let error):
                    self.handleServerCommandError(error: error, command: command)
                    self.action.send(ModelAction.Statement.List.Response(result: .failure(ModelStatementsError.serverCommandError(error: error))))
                    self.statementsUpdating.value[product.id] = .failed
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
    
    //TODO: tests
    func statementsRequestParameters(for product: ProductData, direction: Period.Direction) -> ProductStatementsStorage.Request? {
        
        let days = 60
        
        switch direction {
        case .latest:
            let now = Date()
            
            if let storage = statements.value[product.id] {
                
                guard let period = storage.latestPeriod(days: days, limitDate: now) else {
                   return nil
                }
                
                return .init(period: period, direction: direction, limitDate: now)
                
            } else {
                
                let period = Period(daysBack: days, from: now)
                return .init(period: period, direction: direction, limitDate: now)
            }
            
        case .eldest:
            guard let storage = statements.value[product.id],
                  let limitDate = ProductStatementsStorage.historyLimitDate(for: product),
                  let period = storage.eldestPeriod(days: days, limitDate: limitDate) else { return nil }
            
            return .init(period: period, direction: direction, limitDate: limitDate)
        }
    }
}

//MARK: - Reducers

extension Model {
    
    static func reduce(statements: StatementsData, with update: ProductStatementsStorage.Update, for product: ProductData) -> StatementsData {
        
        var updated = statements
        
        let historyLimitDate = ProductStatementsStorage.historyLimitDate(for: product)
        if let storage = statements[product.id] {
            
            updated[product.id] = storage.updated(with: update, historyLimitDate: historyLimitDate)
            
        } else {
            
            updated[product.id] = ProductStatementsStorage(with: update, historyLimitDate: historyLimitDate)
        }
        
        return updated
    }
}

//MARK: - Error

enum ModelStatementsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: Error)
}
