//
//  Model+Products.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

//MARK: - Actions

typealias ProductsData = [ProductType : [ProductData]]
typealias ProductsDynamicParams = [ServerCommands.ProductController.GetProductDynamicParamsList.Response.List.DynamicListParams]

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
                        let result: Result<ProductDynamicParamsData, Error>
                    }
                }
            }
            
            enum Total {
                
                struct All: Action {}
            }
        }
        
        enum UpdateCustomName {
        
            struct Request: Action {
                
                let productId: ProductData.ID
                let productType: ProductType
                let name: String
            }
            
            enum Response: Action {
                
                case complete(name: String)
                case failed(message: String)
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleProductsUpdateFastAll() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let productsList = products.value.values.flatMap{ $0 }
        let command = ServerCommands.ProductController.GetProductDynamicParamsList(token: token, products: productsList)
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let params = response.data?.dynamicProductParamsList else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    let updatedProducts = self.reduce(products: self.products.value, with: params)
                    self.products.value = updatedProducts
                    
                    do {
                        
                        try self.localAgent.store(self.products.value, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleProductsUpdateFastSingleRequest(_ payload: ModelAction.Products.Update.Fast.Single.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard let command = createCommand() else {
            return
        }
        
        func createCommand() -> ServerCommands.ProductController.GetProductDynamicParams? {
            
            switch payload.productType {
            case .card:
                
                let command = ServerCommands.ProductController.GetProductDynamicParams(token: token, payload: .init(accountId: nil, cardId: payload.productId.description, depositId: nil))
                return command
                
            case .account:
                
                let command = ServerCommands.ProductController.GetProductDynamicParams(token: token, payload: .init(accountId: payload.productId.description, cardId: nil, depositId: nil))
                return command
                
            case .deposit:
                
                let command = ServerCommands.ProductController.GetProductDynamicParams(token: token, payload: .init(accountId: nil, cardId: nil, depositId: payload.productId.description))
                return command
                
            case .loan:
                return nil
            }
        }
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let params = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.products.value = self.reduce(products: self.products.value, with: params, productId: payload.productId)
                    
                    do {
                        
                        try self.localAgent.store(self.products.value, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleProductsUpdateTotalAll() {
        
        guard self.productsUpdateState.value == .idle else {
            return
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
            
            self.productsUpdateState.value = .updating
            
            for productType in ProductType.allCases {
                
                let command = ServerCommands.ProductController.GetProductListByType(token: token, serial: nil, productType: productType)
                
                do {
                    
                    let productsForType = try await productsFetchWithCommand(command: command)
                    self.products.value = reduce(products: self.products.value, with: productsForType, allowed: self.productsAllowed)
                    try self.localAgent.store(self.products.value, serial: nil)
                    
                } catch {
                    
                    self.handleServerCommandError(error: error, command: command)
                }
            }
            
            self.productsUpdateState.value = .idle
        }
    }
    
    func productsFetchWithCommand(command: ServerCommands.ProductController.GetProductListByType) async throws -> [ProductData] {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let products = response.data.productList else {
                            continuation.resume(with: .failure(ModelProductsError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: products)

                    default:
                        continuation.resume(with: .failure(ModelProductsError.statusError(status: response.statusCode, message: response.errorMessage)))
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(ModelProductsError.serverCommandError(error: error.localizedDescription)))
                }
            }
        }
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
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(name: name))
                        
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
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(name: name))
                        
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
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(name: name))
                        
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
                        self.action.send(ModelAction.Products.UpdateCustomName.Response.complete(name: name))
                        
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
}

//MARK: - Reducers

//TODO: tests
extension Model {
    
    func reduce(products: ProductsData, with productsList: [ProductData], allowed: Set<ProductType>) -> ProductsData {
        
        var productsUpdated = products
        
        for productType in ProductType.allCases {
            
            if allowed.contains(productType) {
                
                let productsForType = productsList.filter{ $0.productType == productType }
                
                guard productsForType.isEmpty == false else {
                    continue
                }
                
                productsUpdated[productType] = productsForType
                
            } else {
                
                productsUpdated[productType] = nil
            }
        }
        
        return productsUpdated
    }
    
    func reduce(products: ProductsData, with params: ProductDynamicParamsData, productId: Int) -> ProductsData {
        
        var productsUpdated = ProductsData()
        
        for productType in products.keys {
            
            guard let productsForType = products[productType] else {
                continue
            }
            
            var productsForTypeUpdated = [ProductData]()
            
            for product in productsForType {
                
                if product.id == productId  {
                    
                    product.update(with: params)
                }
                
                productsForTypeUpdated.append(product)
            }
            
            productsUpdated[productType] = productsForTypeUpdated
        }
        
       return productsUpdated
    }
    
    func reduce(products: ProductsData, with params: ProductsDynamicParams) -> ProductsData {
        
        var productsUpdated = ProductsData()
        
        for productType in products.keys {
            
            guard let productsForType = products[productType] else {
                continue
            }
            
            var productsForTypeUpdated = [ProductData]()
            
            for product in productsForType {
                
                if let dynamicParam = params.first(where: { $0.id == product.id })?.dynamicParams {
                    
                    product.update(with: dynamicParam)
                    
                }
                
                productsForTypeUpdated.append(product)
            }
            
            productsUpdated[productType] = productsForTypeUpdated
        }
        
       return productsUpdated
    }
}

//MARK: - Error

enum ModelProductsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
}
