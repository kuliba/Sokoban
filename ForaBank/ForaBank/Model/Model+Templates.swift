//
//  ModelAction+PaymentTemplate.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum PaymentTemplate {
        
        enum Save {
        
            struct Requested: Action {
                
                let name: String
                let paymentOperationDetailId: Int
            }
            
            struct Complete: Action {
                
                let paymentTemplateId: Int
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum Update {
            
            struct Requested: Action {
                
                let name: String?
                let parameterList: [TransferData]?
                let paymentTemplateId: Int
            }
            
            struct Complete: Action {}
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum Delete {
            
            struct Requested: Action {
                
                let paymentTemplateIdList: [Int]
            }
            
            struct Complete: Action {}
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum List {
            
            struct Requested: Action {}
            
            struct Complete: Action {
                
                let paymentTemplates: [PaymentTemplateData]
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
    
    }
}

//MARK: - Handlers

extension Model {
    
    func handleTemplatesListRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.PaymentTemplateController.GetPaymentTemplateList(token: token)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    if let templates = response.data {
                        
                        //TODO: remove when all templates will be implemented
                        let allowed = templates.filter{ self.paymentTemplatesDisplayed.contains($0.type) }
                        
                        // update model data
                        self.paymentTemplates.value = allowed
                       
                        do {
                            
                            // cache tempates data
                            try self.localAgent.store(allowed, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                        
                        self.action.send(ModelAction.PaymentTemplate.List.Complete(paymentTemplates: templates))
                        
                    } else {
                        
                        self.paymentTemplates.value = []
                        
                        do {
                            
                            // delete cached templates data
                            try self.localAgent.clear(type: [PaymentTemplateData].self)
                            
                        } catch {
                            
                            //TODO: set logger
                        }
                        
                        self.action.send(ModelAction.PaymentTemplate.List.Complete(paymentTemplates: []))
                    }

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.action.send(ModelAction.PaymentTemplate.List.Failed(error: error))
            }
        }
    }
    
    func handleTemplatesSaveRequest(_ payload: ModelAction.PaymentTemplate.Save.Requested) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.PaymentTemplateController.SavePaymentTemplate(token: token, payload: .init(name: payload.name, paymentOperationDetailId: payload.paymentOperationDetailId))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    // confirm template saved
                    self.action.send(ModelAction.PaymentTemplate.Save.Complete(paymentTemplateId: response.data.paymentTemplateId))
                    // request all templates from server
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
            }
        }
    }
    
    func handleTemplatesUpdateRequest(_ payload: ModelAction.PaymentTemplate.Update.Requested) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.PaymentTemplateController.UpdatePaymentTemplate(token: token, payload: .init(name: payload.name, parameterList: payload.parameterList, paymentTemplateId: payload.paymentTemplateId))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    // confirm template updated
                    self.action.send(ModelAction.PaymentTemplate.Update.Complete())
                    // request all templates from server
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.action.send(ModelAction.PaymentTemplate.Update.Failed(error: error))
            }
        }
    }
    
    func handleTemplatesDeleteRequest(_ payload: ModelAction.PaymentTemplate.Delete.Requested) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.PaymentTemplateController.DeletePaymentTemplates(token: token, payload: .init(paymentTemplateIdList: payload.paymentTemplateIdList))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    // confirm templete deleted
                    self.action.send(ModelAction.PaymentTemplate.Delete.Complete())
                    // request all templates from server
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.action.send(ModelAction.PaymentTemplate.Delete.Failed(error: error))
            }
        }
    }
}
