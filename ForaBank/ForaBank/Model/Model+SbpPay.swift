//
//  Model+SbpPay.swift
//  Vortex
//
//  Created by Дмитрий on 30.08.2022.
//

import Foundation


extension ModelAction {
    
    enum SbpPay {
        
        enum Register {
            
            struct Request: Action {
                
                let tokenIntent: String
            }
            
            struct Response: Action {
                
                let tokenIntent: String
                let result: ServerCommands.SbpPayController.Result
            }
        }
        
        enum ProcessTokenIntent {
            
            struct Request: Action {
                
                let accountId: String
                let tokenIntent: String
                let result: ServerCommands.SbpPayController.Result
            }
            
            struct Response: Action {
                
                let tokenIntent: String
                let result: ServerCommands.SbpPayController.Result
            }
        }
    }
}

extension Model {
    
    func handleRegisterSbpPay(_ payload: ModelAction.SbpPay.Register.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.SbpPayController.RegisterToken(token: token, payload: .init(tokenIntentId: payload.tokenIntent))
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success:
                self.action.send(ModelAction.SbpPay.Register.Response(
                    tokenIntent: payload.tokenIntent,
                    result: .success
                ))
                
            case .failure(let error):
                self.action.send(ModelAction.SbpPay.Register.Response(
                    tokenIntent: payload.tokenIntent,
                    result: .failed
                ))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func processTokenIntent(_ payload: ModelAction.SbpPay.ProcessTokenIntent.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.SbpPayController.ProcessToken(
            token: token,
            payload: .init(
                tokenIntentId: payload.tokenIntent,
                accountId: payload.accountId,
                status: payload.result
            )
        )
        
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                
                guard let data = response.data else {
                    self.action.send(ModelAction.SbpPay.ProcessTokenIntent.Response(
                        tokenIntent: payload.tokenIntent,
                        result: .failed
                    ))
                    self.handleServerCommandEmptyData(command: command)
                    return
                }
                
                switch data {
                case .success:
                    
                    self.action.send(ModelAction.SbpPay.ProcessTokenIntent.Response(
                        tokenIntent: payload.tokenIntent,
                        result: .success
                    ))
                    
                case .failed:
                    
                    self.action.send(ModelAction.SbpPay.ProcessTokenIntent.Response(
                        tokenIntent: payload.tokenIntent,
                        result: .failed
                    ))
                }
                
            case .failure(let error):
                self.action.send(ModelAction.SbpPay.ProcessTokenIntent.Response(
                    tokenIntent: payload.tokenIntent,
                    result: .failed
                ))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
}
