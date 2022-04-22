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
                
                let result: Result<[ProductStatementData], Error>
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
                        self.statement.value = statement
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        return
                    }
                case .failure(let error):
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
                        self.statement.value = statement
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        return
                    }
                case .failure(let error):
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
                        self.statement.value = statement
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        return
                    }
                case .failure(let error):
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
                        self.statement.value = statement
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        return
                    }
                case .failure(let error):
                    self.handleServerCommandError(error: error, command: command)
                }
            }
        }
    }
}

