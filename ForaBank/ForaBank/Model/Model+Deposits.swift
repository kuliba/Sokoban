//
//  Model+Deposits.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Deposits {
    
        enum List {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<[DepositProductData], Error>
            }
        }
        
        enum Info {
            
            struct Request: Action {
                
                let id: Int
            }
            
            enum Response: Action {
                
                case success(data: DepositInfoDataItem)
                case failure(message: String)
            }
        }
        
        enum Close {
            
            struct Request: Action {
                
                let payload: ServerCommands.DepositController.CloseDeposit.Payload
            }
            
            enum Response: Action {
                
                case success(data: ServerCommands.DepositController.CloseDeposit.Response.TransferData)
                case failure(message: String)
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleDepositsListRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.DepositController.GetDepositProductList(token: token)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let deposits = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.deposits.value = deposits
                    self.action.send(ModelAction.Deposits.List.Response(result: .success(deposits)))
                    
                    do {
                        
                        try self.localAgent.store(deposits, serial: nil)
                        
                    } catch {
                        
                        //TODO: log error
                        print("handleDepositsListRequest: caching error: \(error.localizedDescription)")
                    }

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
            self.action.send(ModelAction.Deposits.List.Response(result: .failure(error)))
            }
        }
    }
    
    func handleCloseDepositRequest(_ payload: ModelAction.Deposits.Close.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.CloseDeposit(token: token, payload: .init(id: payload.payload.id, name: payload.payload.name, startDate: payload.payload.startDate, endDate: payload.payload.endDate, statementFormat: payload.payload.statementFormat, accountId: payload.payload.accountId, cardId: payload.payload.cardId))
        serverAgent.executeCommand(command: command) { [weak self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        return
                    }
                    
                    self?.action.send(ModelAction.Deposits.Close.Response.success(data: data))
                    
                default:
                    
                    if let error = response.errorMessage {
                        
                        self?.action.send(ModelAction.Deposits.Close.Response.failure(message: error))
                    }
                    
                    self?.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self?.action.send(ModelAction.Deposits.Close.Response.failure(message: error.localizedDescription))
            }
        }
    }
    
    func handleDepositsInfoRequest(id: Int) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.GetDepositInfo(token: token, payload: .init(id: id))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let info = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    self.action.send(ModelAction.Deposits.Info.Response.success(data: info))

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
}
