//
//  Model+Statement.swift
//  ForaBank
//
//  Created by Дмитрий on 12.04.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Statement {
        
        enum List {
            
            struct Request: Action {
                let productId: ProductData.ID
                let productType: ProductType
            }
            
            struct Response: Action {
                
                let result: Result
                
                enum Result {
                    case success
                    case failure(message: String)
                }
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleStatementRequest(_ payload: ModelAction.Statement.List.Request) {
        guard let token = token else {
            return
        }
        
        switch payload.productType {
        case .card:
            
            let command = ServerCommands.CardController.GetCardStatement(token: token, payload: .init(cardNumber: nil, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil))
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let statement = response.data else { return }
                        self.statement.value = self.reduce(statements: self.statement.value, with: statement, productId: payload.productId)
                        
                        do {
                            try self.localAgent.store(self.statement.value, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                        
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Statement.List.Response(result: .failure(message: response.errorMessage ?? "Возникла техническая ошибка. Свяжитесь с поддержкой банка для уточнения")))
                        return
                    }
                case .failure(let error):
                    self.action.send(ModelAction.Statement.List.Response(result: .failure(message: error.localizedDescription)))
                    self.handleServerCommandError(error: error, command: command)
                }
            }
            
        case .account:
            
            let command = ServerCommands.AccountController.GetAccountStatement(token: token, accountNumber: nil, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil)
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let statement = response.data else { return }
                        self.statement.value = self.reduce(statements: self.statement.value, with: statement, productId: payload.productId)
                        
                        do {
                            try self.localAgent.store(self.statement.value, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Statement.List.Response(result: .failure(message: response.errorMessage ?? "Возникла техническая ошибка. Свяжитесь с поддержкой банка для уточнения")))
                        return
                    }
                case .failure(let error):
                    self.action.send(ModelAction.Statement.List.Response(result: .failure(message: error.localizedDescription)))
                    self.handleServerCommandError(error: error, command: command)
                }
            }
        case .deposit:
            
            let command = ServerCommands.DepositController.GetDepositStatement(token: token, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil)
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let statement = response.data else { return }
                        self.statement.value = self.reduce(statements: self.statement.value, with: statement, productId: payload.productId)
                        
                        do {
                            try self.localAgent.store(self.statement.value, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Statement.List.Response(result: .failure(message: response.errorMessage ?? "Возникла техническая ошибка. Свяжитесь с поддержкой банка для уточнения")))
                        return
                    }
                case .failure(let error):
                    self.action.send(ModelAction.Statement.List.Response(result: .failure(message: error.localizedDescription)))
                    self.handleServerCommandError(error: error, command: command)
                }
            }
        default:
            
            let command = ServerCommands.CardController.GetCardStatement(token: token, payload: .init(cardNumber: nil, endDate: nil, id: payload.productId, name: nil, startDate: nil, statementFormat: nil))
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let statement = response.data else { return }
                        self.statement.value = self.reduce(statements: self.statement.value, with: statement, productId: payload.productId)
                        
                        do {
                            try self.localAgent.store(self.statement.value, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Statement.List.Response(result: .failure(message: response.errorMessage ?? "Возникла техническая ошибка. Свяжитесь с поддержкой банка для уточнения")))
                        return
                    }
                case .failure(let error):
                    self.action.send(ModelAction.Statement.List.Response(result: .failure(message: error.localizedDescription)))
                    self.handleServerCommandError(error: error, command: command)
                }
            }
        }
    }
    
    func reduce(statements: ProductStatementDataCacheble, with statementData: [ProductStatementData], productId: Int) -> ProductStatementDataCacheble {
        
        var statementUpdated = statements
        let filteredByKeys = statementUpdated.productStatement.filter({$0.key == productId})
        
        if filteredByKeys.count == 0 {
            
        } else {
            
            statementUpdated.productStatement.updateValue(statementData, forKey: productId)
        }
        
        return statementUpdated
        
    }
}

