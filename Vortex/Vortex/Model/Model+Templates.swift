//
//  ModelAction+PaymentTemplate.swift
//  Vortex
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
            
            struct Complete: Action {
                
                let paymentTemplateId: Int
                let newName: String
            }
            
            struct Failed: Action {
                
                let paymentTemplateId: Int
                let error: Error
            }
        }
        
        enum Delete {
            
            struct Requested: Action {
                
                let paymentTemplateIdList: [Int]
            }
            
            struct Complete: Action {
               
                let paymentTemplateIdList: [Int]
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum Sort {
            
            struct Requested: Action {
                
                let sortDataList: [PaymentTemplateData.SortData]
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

//MARK:- product Templates
extension Model {
    
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
}

//MARK: - paymentTemplates
extension Model {
    
    static func reduce(images: [String: ImageData],
                       with data: [PaymentTemplateData])
    async -> [String: ImageData] {
        
        let prefixKey = "Template"
        let dataIds = data.map(\.id)
        let cacheIds = Set(images.keys
            .filter { $0.hasPrefix(prefixKey) }
            .compactMap { Int($0.dropFirst(prefixKey.count)) })
        
        let fullDiff = cacheIds.symmetricDifference(dataIds)
        let addDiff = fullDiff.intersection(dataIds)
        let delDiff = fullDiff.intersection(cacheIds)
        
        var localImages = images
        
        for id in delDiff { //delete images
            
            localImages.removeValue(forKey: "\(prefixKey)\(id)")
        }
        
        for id in addDiff { //add images
            
            if let template = data.first(where: { $0.id == id }),
               let svgImage = template.svgImage,
               let imgData = ImageData(with: svgImage) {
                
                localImages["\(prefixKey)\(id)"] = imgData
            }
        }
        
        return localImages
    }
    
    func handleTemplatesListRequest() {
        
        guard let token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard !self.paymentTemplatesUpdating.value else { return }
        self.paymentTemplatesUpdating.send(true)
        
        let serial = localAgent.serial(for: [PaymentTemplateData].self)
        
        let command = ServerCommands.PaymentTemplateController.GetPaymentTemplateList
                        .init(token: token, serial: serial)
        
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            self.paymentTemplatesUpdating.send(false)
            
            switch result {
            case let .success(response):
                
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data, serial != data.serial
                    else { return }
                    
                    Task {
                        
                        let updatedImages = await Self.reduce(
                            images: self.images.value,
                            with: data.templateList
                        )

                        if self.images.value != updatedImages {

                            self.images.value = updatedImages
                            try? self.localAgent.store(self.images.value, serial: nil)
                        }
                    }
                    
                    // update model data
                    self.paymentTemplates.value = data.templateList
                       
                    do {
                            
                    // cache templates data with new serial
                        try self.localAgent.store(data.templateList, serial: data.serial)
                            
                    } catch {
                            
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                    self.action.send(ModelAction.PaymentTemplate.List.Complete
                        .init(paymentTemplates: data.templateList))

                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                    
                    self.action.send(ModelAction.PaymentTemplate.List.Failed
                        .init(error: ResponseError(message: response.errorMessage)))
                }
            case .failure(let error):
                
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.PaymentTemplate.List.Failed(error: error))
            }
        }
    }
    
    func handleTemplatesSaveRequest(_ payload: ModelAction.PaymentTemplate.Save.Requested) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentTemplateController.SavePaymentTemplate
                        .init(token: token,
                              payload: .init(name: payload.name,
                                             paymentOperationDetailId: payload.paymentOperationDetailId))
        
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
                    self.action.send(ModelAction.PaymentTemplate.Save.Complete
                                        .init(paymentTemplateId: templateData.paymentTemplateId))
                    // request all templates from server
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.PaymentTemplate.Save.Failed
                                        .init(error: ResponseError(message: response.errorMessage)))
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
            }
        }
    }
    
    func handleTemplatesUpdateRequest(_ payload: ModelAction.PaymentTemplate.Update.Requested) {
        
        guard let token = token
        else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentTemplateController.UpdatePaymentTemplate
                        .init(token: token,
                              payload: .init(name: payload.name,
                                             parameterList: payload.parameterList,
                                             paymentTemplateId: payload.paymentTemplateId))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    // confirm template updated
                    self.action.send(ModelAction.PaymentTemplate.Update.Complete
                        .init(paymentTemplateId: payload.paymentTemplateId,
                              newName: payload.name ?? ""))
                    // request all templates from server
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                    
                    self.action.send(ModelAction.PaymentTemplate.Update.Failed
                        .init(paymentTemplateId: payload.paymentTemplateId,
                              error: ResponseError(message: response.errorMessage)))
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.PaymentTemplate.Update.Failed
                    .init(paymentTemplateId: payload.paymentTemplateId,
                          error: error))
            }
        }
    }
    
    func handleTemplatesDeleteRequest(_ payload: ModelAction.PaymentTemplate.Delete.Requested) {
        
        guard let token = token
        else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentTemplateController.DeletePaymentTemplates
                        .init(token: token,
                              payload: .init(paymentTemplateIdList: payload.paymentTemplateIdList))
        
        serverAgent.executeCommand(command: command) { [payload] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    self.action.send(ModelAction.PaymentTemplate.Delete.Complete
                                    .init(paymentTemplateIdList: payload.paymentTemplateIdList))
                    
                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                    self.action.send(ModelAction.PaymentTemplate.Delete.Failed
                                    .init(error: ResponseError(message: response.errorMessage)))
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.PaymentTemplate.Delete.Failed(error: error))
            }
        }
    }
    
    func handleTemplatesSortRequest(_ payload: ModelAction.PaymentTemplate.Sort.Requested) {
        
        guard let token = token
        else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PaymentTemplateController.SortingPaymentTemplates
                        .init(token: token,
                              payload: .init(sortDataList: payload.sortDataList))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    // confirm template sorting
                    self.action.send(ModelAction.PaymentTemplate.Sort.Complete())
                    // request all templates from server
                    self.action.send(ModelAction.PaymentTemplate.List.Requested())
                    
                default:
                    self.handleServerCommandStatus(command: command,
                                                   serverStatusCode: response.statusCode,
                                                   errorMessage: response.errorMessage)
                    
                    self.action.send(ModelAction.PaymentTemplate.Sort.Failed
                                        .init(error: ResponseError(message: response.errorMessage)))
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.PaymentTemplate.Sort.Failed(error: error))
            }
        }
    }
    
    struct ResponseError: Error {

        let message: String?
    }
}
