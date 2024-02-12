//
//  Model+Deposits.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation
import ServerAgent

//MARK: - Action

typealias DepositsInfoData = [ProductData.ID: DepositInfoDataItem]

extension ModelAction {
    
    enum Deposits {
    
        enum List {
            
            struct Request: Action {}
            
            enum Response: Action {
                
                case success(data: [DepositProductData])
                case failure(message: String)
            }
        }
        
        enum Info {
            
            struct All: Action {}
            
            enum Single {
            
                struct Request: Action {
                    
                    let productId: ProductData.ID
                }
                
                enum Response: Action {
                    
                    case success(data: DepositInfoDataItem)
                    case failure(message: String)
                }
            }
        }
        
        enum Close {
            
            struct Request: Action {
                
                let payload: ServerCommands.DepositController.CloseDeposit.Payload
            }
            
            enum Response: Action {
                
                case success(data: CloseProductTransferData)
                case failure(message: String)
            }
        }
        
        struct BeforeClosing {
        
            struct Request: Action {
             
                let depositId: Int
                let operDate: Date
            }
            
            enum Response: Action {
                
                case success(data: Double)
                case failure(message: String)
            }
        }
        
        struct CloseNotified: Action {
            
            let productId: ProductData.ID
        }
    }
}

//MARK: - Helpers
extension Model {
    func sendCloseDepositRequest(productFrom: ProductDepositData, productTo: ProductData) throws {
        //закрытие вклада
        switch productTo {
            
        case let productTo as ProductCardData:
            self.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: productFrom.depositId, name: productFrom.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: nil, cardId: productTo.cardId)))
            
        case let productTo as ProductAccountData:
                
            self.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: productFrom.depositId, name: productFrom.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: productTo.id, cardId: nil)))
            
        case let productTo as ProductDepositData:
                
            self.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: productFrom.depositId, name: productFrom.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: productTo.accountId, cardId: nil)))

        default:
            throw ModelDepositsError.closeDeposit(.productToUnexpectedType)
        }
        
    }

}

//MARK: - Handlers

extension Model {
    
    func handleDepositsSerial() -> String? {
        
        if localAgent.load(type: [DepositProductData].self) != nil {
            return localAgent.serial(for: [DepositProductData].self)
         
        } else {
            return nil
        }
    }
    
    func handleDepositsListRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
    
        let serial = handleDepositsSerial()
        
        let command = ServerCommands.DepositController.GetDepositProductList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                    
                case .ok:
                    
                    guard serial != response.data?.serial else { return }
                   
                    guard
                        let data = response.data,
                        let deposits = data.list
                    else {
                        self.action.send(ModelAction.Deposits.List.Response.failure(message: self.emptyDataErrorMessage))
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.deposits.value = deposits
                    self.action.send(ModelAction.Deposits.List.Response.success(data: deposits))
                    
                    do {
                        
                        try self.localAgent.store(deposits, serial: data.serial)
                        
                    } catch(let error) {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }

                default:
                    self.action.send(ModelAction.Deposits.List.Response.failure(message: self.defaultErrorMessage))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.action.send(ModelAction.Deposits.List.Response.failure(message: self.defaultErrorMessage))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleCloseDepositRequest(_ payload: ModelAction.Deposits.Close.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.CloseDeposit(token: token, payload: .init(id: payload.payload.id, name: payload.payload.name, startDate: payload.payload.startDate, endDate: payload.payload.endDate, statementFormat: payload.payload.statementFormat, accountId: payload.payload.accountId, cardId: payload.payload.cardId))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Deposits.Close.Response.failure(message: self.emptyDataErrorMessage))
                        return
                    }
                    
                    self.action.send(ModelAction.Deposits.Close.Response.success(data: data))
                    
                default:
                    
                    if let error = response.errorMessage {
                        
                        self.action.send(ModelAction.Deposits.Close.Response.failure(message: error))
                        
                    } else {
                        
                        self.action.send(ModelAction.Deposits.Close.Response.failure(message: self.defaultErrorMessage))
                    }
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Deposits.Close.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleBeforeClosingRequest(_ payload: ModelAction.Deposits.BeforeClosing.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.GetDepositRestBeforeClosing(token: token, dateFormatter: DateFormatterISO8601(), depositId: payload.depositId, operDate: payload.operDate)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
//                        self.action.send(ModelAction.Deposits.BeforeClosing.Response.failure(message: self.emptyDataErrorMessage))
//                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Deposits.BeforeClosing.Response.success(data: 10))

                        return
                    }
                    
                    self.action.send(ModelAction.Deposits.BeforeClosing.Response.success(data: data))
                    
                default:
                    
                    if let error = response.errorMessage {
                        
                        self.action.send(ModelAction.Deposits.BeforeClosing.Response.failure(message: error))
                    } else {
                        
                        self.action.send(ModelAction.Deposits.BeforeClosing.Response.failure(message: self.defaultErrorMessage))
                    }
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Deposits.BeforeClosing.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleDepositsInfoAllRequest() {
        
        guard let depositsProducts = products.value[.deposit], depositsProducts.isEmpty == false else {
            return
        }
        
        for deposit in depositsProducts {
            
            action.send(ModelAction.Deposits.Info.Single.Request(productId: deposit.id))
        }
    }
    
    func handleDepositsInfoSingleRequest(_ payload: ModelAction.Deposits.Info.Single.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.GetDepositInfo(token: token, productId: payload.productId)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let info = response.data else {
                        self.action.send(ModelAction.Deposits.Info.Single.Response.failure(message: self.emptyDataErrorMessage))
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.action.send(ModelAction.Deposits.Info.Single.Response.success(data: info))
                    self.depositsInfo.value = Self.reduce(depositsInfoData: self.depositsInfo.value, productId: payload.productId, info: info)
                    
                    do {
                        
                        try self.localAgent.store(self.depositsInfo.value, serial: nil)
                        
                    } catch(let error){
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
  
                default:
                    self.action.send(ModelAction.Deposits.Info.Single.Response.failure(message: self.defaultErrorMessage))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Deposits.Info.Single.Response.failure(message: self.defaultErrorMessage))
            }
        }
    }
    
    func handleDidShowCloseAlert(_ payload: ModelAction.Deposits.CloseNotified) {
        
        self.depositsCloseNotified.insert(.init(depositId: payload.productId))
        
        do {
            
            try self.localAgent.store(self.depositsCloseNotified, serial: nil)
            
        } catch(let error) {
            
            LoggerAgent.shared.log(category: .cache, message: "Caching error: \(error)")
        }
    }
}

//MARK: - Reducers

extension Model {
    
    var depositCloseBirjevoyURL: String { "https://finuslugi.ru/" }
    
    static func reduce(depositsInfoData: DepositsInfoData, productId: ProductData.ID, info: DepositInfoDataItem) -> DepositsInfoData {
        
        var updated = depositsInfoData
        updated[productId] = info
        
        return updated
    }
}

//MARK: - Deposits Error

enum ModelDepositsError: Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
    case unauthorizedCommandAttempt
    case closeDeposit(CloseDeposit)
    
    enum CloseDeposit: LocalizedError {
        case productToUnexpectedType
    }
}
