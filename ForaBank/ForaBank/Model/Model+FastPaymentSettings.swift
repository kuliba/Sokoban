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
                let result: Result<[FastPaymentContractFullInfoType], Error>
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
                    
                    guard let fastPaymentContractFull = response.data
                    else {
                        self.action
                            .send(ModelAction
                                .FastPaymentSettings
                                .ContractFindList
                                .Response(result: .failure(ModelFastPaymentSettingsError
                                    .emptyData(message: response.errorMessage))))
                        return
                    }
                    
                    self.fastPaymentContractFullInfo.value = fastPaymentContractFull
                    self.action.send(ModelAction
                                    .FastPaymentSettings
                                    .ContractFindList
                                    .Response(result: .success(fastPaymentContractFull)))
                    
                    //cache
                    do {
                        
                        try self.localAgent.store(self.fastPaymentContractFullInfo.value,
                                                  serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.action.send(ModelAction
                                    .FastPaymentSettings
                                    .ContractFindList
                                    .Response(result: .failure(ModelFastPaymentSettingsError
                                        .statusError(status: response.statusCode,
                                                     message: response.errorMessage))))
                    
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                }
            
            case .failure(let error):
                
                self.action.send(ModelAction
                                .FastPaymentSettings
                                .ContractFindList
                                .Response(result: .failure(ModelFastPaymentSettingsError
                                    .serverCommandError(error: error))))
            }
            
        }
    }
}

//MARK: - Error

enum ModelFastPaymentSettingsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: Error)
    case cacheError(Error)
}
