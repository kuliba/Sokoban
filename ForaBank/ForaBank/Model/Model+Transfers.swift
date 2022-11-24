//
//  Model+Transfers.swift
//  ForaBank
//
//  Created by Дмитрий on 02.06.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Transfers {
        
        enum CreateInterestDepositTransfer {
            
            struct Request: Action {
                
                let payload: ServerCommands.TransferController.CreateInterestDepositTransfer.Payload
            }
            
            enum Response: Action {
                
                case success(data: CreateTransferResponseData)
                case failure(message: String)
            }
        }
        
        enum TransferLimit {
            
            struct Request: Action {}
            
            enum Response: Action {
                
                case limit(data: TransferLimitData)
                case noLimit
                case failure(Error)
            }
        }
        
        enum ResendCode {
            
            struct Request: Action {}

            enum Response: Action {
                
                case success(data: VerificationCodeData)
                case failure(message: String)
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleCreateInterestDepositTransferRequest(_ payload: ModelAction.Transfers.CreateInterestDepositTransfer.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.TransferController.CreateInterestDepositTransfer(token: token, payload: payload.payload)
        serverAgent.executeCommand(command: command) { [weak self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        return
                    }
                    
                    self?.action.send(ModelAction.Transfers.CreateInterestDepositTransfer.Response.success(data: data))
                    
                default:
                        
                    if let error = response.errorMessage {
                        
                        self?.action.send(ModelAction.Transfers.CreateInterestDepositTransfer.Response.failure(message: error))
                    }
                    
                    self?.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self?.action.send(ModelAction.Transfers.CreateInterestDepositTransfer.Response.failure(message: error.localizedDescription))
            }
        }
    }
    
    func handleTransferLimitRequest(_ payload: ModelAction.Transfers.TransferLimit.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.TransferController.GetTransferLimit(token: token)
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    if let data = response.data {
                        
                        self.action.send(ModelAction.Transfers.TransferLimit.Response.limit(data: data))
                    } else {
                        
                        self.action.send(ModelAction.Transfers.TransferLimit.Response.noLimit)
                    }
                    
                default:
                    
                    self.action.send(ModelAction.Transfers.TransferLimit.Response.failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage)))
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    
                }
            case .failure(let error):
                
                self.action.send(ModelAction.Transfers.TransferLimit.Response.failure(error))
                
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleTransfersResendCodeRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.TransferController.GetVerificationCode(token: token)
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                        
                    self.action.send(ModelAction.Transfers.ResendCode.Response.success(data: data))
                    
                default:

                    if let errorMessage = response.errorMessage {

                        self.action.send(ModelAction.Transfers.ResendCode.Response.failure(message: errorMessage))
                    } else {
                        
                        self.action.send(ModelAction.Transfers.ResendCode.Response.failure(message: self.defaultErrorMessage))
                    }
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    
                }
            case .failure(let error):
                
                self.action.send(ModelAction.Transfers.ResendCode.Response.failure(message: error.localizedDescription))
                
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
}
