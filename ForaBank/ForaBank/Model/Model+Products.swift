//
//  Model+Products.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

//MARK: - Handlers

extension Model {
    
    func handleProductsUpdateFastAll() {
        
        
    }
    
    func handleProductsUpdateFastSingleRequest(_ payload: ModelAction.Products.Update.Fast.Single.Request) {
        
        
    }
    
    func handleProductsUpdateTotalAll() {
        
        
    }
    
    func handleProductsUpdateTotalSingleRequest(_ payload: ModelAction.Products.Update.Total.Single.Request) {
        
        
    }
    
    func handleProductsUpdateCustomName(_ payload: ModelAction.Products.UpdateCustomName.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let id = payload.productId
        let name = payload.name
        let defaultErrorMessage = "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."
    
        switch payload.productType {
        case .card:
            let command = ServerCommands.CardController.SaveCardName(token: token, payload: .init(cardNumber: nil, endDate: nil, id: id, name: name, startDate: nil, statementFormat: nil))
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(productId: payload.productId, name: name))
                        
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: response.errorMessage ?? defaultErrorMessage))
                    }
                case .failure(let error):
                    self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
                    self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: defaultErrorMessage))
                }
            }
            
        case .account:
            let command = ServerCommands.AccountController.SaveAccountName(token: token, payload: .init(accountNumber: nil, endDate: nil, id: id, name: name, startDate: nil, statementFormat: nil))
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(productId: payload.productId, name: name))
                        
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: response.errorMessage ?? defaultErrorMessage))
                    }
                case .failure(let error):
                    self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
                    self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: defaultErrorMessage))
                }
            }
            
        case .deposit:
            let command = ServerCommands.DepositController.SaveDepositName(token: token, payload: .init(endDate: nil, id: id, name: name, startDate: nil, statementFormat: nil))
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(productId: payload.productId, name: name))
                        
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: response.errorMessage ?? defaultErrorMessage))
                    }
                case .failure(let error):
                    self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
                    self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: defaultErrorMessage))
                }
            }
            
        case .loan:
            let command = ServerCommands.LoanController.SaveLoanName(token: token, payload: .init(endDate: nil, id: id, name: name, startDate: nil, statementFormat: nil))
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(productId: payload.productId, name: name))
                        
                    default:
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message: response.errorMessage ?? defaultErrorMessage))
                    }
                case .failure(let error):
                    self.action.send(ModelAction.PaymentTemplate.Save.Failed(error: error))
                    self.action.send(ModelAction.Products.UpdateCustomName.Response.failed(message:  defaultErrorMessage))
                }
            }
        }
    }
    
    func reduce(products: [ProductType: [ProductData]], with productsData: [ProductData]) -> [ProductType: [ProductData]] {
        
        var productsUpdated = products
        
        for productType in ProductType.allCases {
            
            let productsTypeData = productsData.filter{ $0.productType == productType }
            
            guard productsTypeData.isEmpty == false else {
                continue
            }
            
            productsUpdated[productType] = productsTypeData
        }
        
        return productsUpdated
    }
    
    func reduce(products: [ProductType: [ProductData]], with params: ProductDynamicParams) -> [ProductType: [ProductData]] {
        
        let productType = params.type
        
        guard let productsTypeData = products[productType] else {
            return products
        }
        
        var productsUpdated = products
        var productsTypeDataUpdated = [ProductData]()
        
        for product in productsTypeData {
            
            if product.id == params.id  {
                
                let productUpdated = product.updated(with: params)
                productsTypeDataUpdated.append(productUpdated)
                
            } else {
                
                productsTypeDataUpdated.append(product)
            }
        }
       
        productsUpdated[productType] = productsTypeDataUpdated
        
        return productsUpdated
    }
}

//MARK: - Actions

extension ModelAction {
    
    enum Products {
    
        enum Update {
        
            enum Fast {
                
                struct All: Action {}
                
                enum Single {
                    
                    struct Request: Action {
                        
                        let productId: ProductData.ID
                        let productType: ProductType
                    }
                    
                    struct Response: Action {
                        
                        let productId: ProductData.ID
                        let productType: ProductType
                        let result: Result<ProductDynamicParams, Error>
                    }
                }
            }
            
            enum Total {
                
                struct All: Action {}
                
                enum Single {
                
                    struct Request: Action {
                        
                        let productType: ProductType
                    }
                    
                    struct Response: Action {

                        let productType: ProductType
                        let result: Result<[ProductData], Error>
                    }
                }
            }
        }
        
        enum UpdateCustomName {
        
            struct Request: Action {
                
                let productId: ProductData.ID
                let productType: ProductType
                let name: String
            }
            
            enum Response: Action {
                
                case complete(productId: ProductData.ID, name: String)
                case failed(message: String)
            }
        }
    }
}
