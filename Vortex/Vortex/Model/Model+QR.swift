//
//  Model+QR.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.11.2022.
//

import Foundation

extension ModelAction {
    
    enum QRAction {
        
        enum SendFailData {
            
            struct Request: Action {
                
                let failData: QRMapping.FailData
            }
        }
    }
}

//MARK: - Handlers

extension Model {
 
    func handleQRActionSendFailData(_ payload: ModelAction.QRAction.SendFailData.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.QRController.SetQRFailData(token: token, payload: payload.failData)
        serverAgent.executeCommand(command: command) { [unowned self] result in

            switch result {
            case .success(let response):

                switch response.statusCode {
                case .ok:
                    break
                    
                default:
                    handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }

            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
}
