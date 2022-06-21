//
//  Model+FastPaymentSettings.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 21.06.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum FastPaymentSettings {
        
        enum ContractFindList {
            
            struct Request: Action {}
            
            struct Response: Action {
                let result: Result<[FastPaymentContractFullInfoType]?, Error>
            }
        
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleContractFindListRequest() {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands
                        .FastPaymentController
                        .FastPaymentContractFindList(token: token)

        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    if let fastPaymentContractFull = response.data {
                     
                        self.fastPaymentContractFullInfo.value = fastPaymentContractFull
                        self.action.send(ModelAction
                                        .FastPaymentSettings
                                        .ContractFindList
                                        .Response(result: .success(fastPaymentContractFull)))
                    } else {
                        
                        self.fastPaymentContractFullInfo.value = nil
                        self.action.send(ModelAction
                                        .FastPaymentSettings
                                        .ContractFindList
                                        .Response(result: .success(nil)))
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            case .failure(let error):
                
                self.action.send(ModelAction
                                .FastPaymentSettings
                                .ContractFindList
                                .Response(result: .failure(error)))
            }
            
        }
    }
}
