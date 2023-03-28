//
//  ModelAction+PaymentTemplate.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum ProductTemplate {
        
        enum List {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<[ProductTemplateData], ModelError>
            }
        }
        
        enum Delete {
            
            struct Request: Action {
                
                let productTemplateId: Int
            }
            
            enum Response: Action {
                
                case complete
                case failed(ModelError)
            }
        }
    }
    
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

//MARK: - Helpers

extension Model {
    
    func productTemplate(for templateId: String) -> ProductTemplateData? {
        
        guard let templateId = Int(templateId),
              let data = self.productTemplates.value.first(where: { $0.id == templateId })
        else { return nil }
        
        return data
    }
}

//MARK: - Handlers

extension Model {
    
//product Templates
    
    func handleProductTemplatesListRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        let command = ServerCommands.ProductTemplateController.GetProductTemplateList(token: token)
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    if let templates = response.data {
                        
                        // update model data
                        self.productTemplates.value = templates
                       
                        do {
                            
                            // cache tempates data
                            try self.localAgent.store(templates, serial: nil)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
                        
                        self.action.send(ModelAction.ProductTemplate.List.Response(result: .success(templates)))
                        
                    } else {
                        
                        self.action.send(ModelAction.ProductTemplate.List.Response(result: .failure(.emptyData(message: response.errorMessage))))
                        self.handleServerCommandEmptyData(command: command)
                    }

                default:
                    self.action.send(ModelAction.ProductTemplate.List.Response(result: .failure(.statusError(status: response.statusCode, message: response.errorMessage))))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
    
                }
                
            case .failure(let error):
                self.action.send(ModelAction.ProductTemplate.List.Response(result: .failure(.serverCommandError(error: error.localizedDescription))))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleProductTemplateDeleteRequest(_ payload: ModelAction.ProductTemplate.Delete.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.ProductTemplateController.DeleteProductTemplate
                        .init(token: token, productId: payload.productTemplateId)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    self.action.send(ModelAction.ProductTemplate.Delete.Response.complete)
                    
                default:
                    self.action.send(ModelAction.ProductTemplate.Delete.Response.failed(.statusError(status: response.statusCode, message: response.errorMessage)))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.action.send(ModelAction.ProductTemplate.Delete.Response.failed(.serverCommandError(error: error.localizedDescription)))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }

    
//paymentTemplates
    
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
                    guard let templateData = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    // confirm template saved
                    self.action.send(ModelAction.PaymentTemplate.Save.Complete(paymentTemplateId: templateData.paymentTemplateId))
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
