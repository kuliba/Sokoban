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
                
                case success(data: ServerCommands.TransferController.CreateInterestDepositTransfer.Response.CreateTransferResponseData)
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
}
