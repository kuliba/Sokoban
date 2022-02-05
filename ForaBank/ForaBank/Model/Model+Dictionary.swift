//
//  Model+Dictionary.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum Dictionary {

        enum AnywayOperators {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    // Anyway Operators
    
    func handleDictionaryAnywayOperatorsRequest(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetAnywayOperatorsList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.operatorGroupList, serial: data.serial)
                        
                    } catch {
                        
                        //TODO: os log
                        print(error.localizedDescription)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.action.send(ModelAction.PaymentTemplate.Delete.Failed(error: error))
            }
        }
    }
}
