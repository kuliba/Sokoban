//
//  Model+Products.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

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
        
        let command = ServerCommands.ProductController.GetProductDynamicParamsList(token: token, products: productForCache(products: self.products.value))
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let params = response.data?.dynamicProductParamsList else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    let updatedProducts = self.updatedListValue(products: self.products.value, with: params)
                    
                    self.products.value = updatedProducts
                    
                    do {
                        
                        let productList = self.productForCache(products: updatedProducts)
                        try self.localAgent.store(productList, serial: nil)
                        
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
                        let productList = self.productForCache(products: self.products.value)
                        try self.localAgent.store( productList, serial: nil)
                        
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
                
                let command = ServerCommands.ProductController.GetProductListByType(token: token, serial: localAgent.serial(for: [ProductData].self), productType: productType)
                
                do {
                    
                    let productsType = try await fetchProductsWithCommand(command: command)
                    self.products.value = reduce(products: self.products.value, with: productsType)
                    
                } catch {
                    
                    self.handleServerCommandError(error: error, command: command)
                }
            }
            
            self.productsUpdateState.value = .idle
        }
    }
    
    func fetchProductsWithCommand(command: ServerCommands.ProductController.GetProductListByType) async throws -> [ProductData] {
        
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
                        
                        do {
                            try self.localAgent.store(products, serial: response.data.serial)
                            
                        } catch {
                            
                            self.handleServerCommandCachingError(error: error, command: command)
                        }
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
    
    func reduce(products: [ProductType: [ProductData]], with productsData: [ProductData]) -> [ProductType: [ProductData]] {
        
        var productsUpdated = products
        
        for productType in self.productsAllowed.uniqued() {
            
            let productsTypeData = productsData.filter{ $0.productType == productType }
            
            guard productsTypeData.isEmpty == false else {
                continue
            }
            
            productsUpdated[productType] = productsTypeData
        }
        
        return productsUpdated
    }
    
    func reduce(products: [ProductType: [ProductData]], with params: ProductDynamicParamsData, productId: Int) -> [ProductType: [ProductData]] {
        
        let productsUpdated = self.productForCache(products: products)
        var productsDataUpdated = [ProductData]()
        
        for product in productsUpdated {
            
            if product.id == productId  {
                
                product.updated(with: params)
                productsDataUpdated.append(product)
                
            } else {
                
                productsDataUpdated.append(product)
            }
        }
        
        let productUpdateResult = reduce(products: self.products.value, with: productsDataUpdated)
        
        return productUpdateResult
    }
    
    func updatedListValue(products: [ProductType: [ProductData]], with params: [ServerCommands.ProductController.GetProductDynamicParamsList.Response.List.DynamicListParams]) -> [ProductType: [ProductData]] {
        
        let productsList = productForCache(products: products)

        for product in productsList {

            if params.contains(where: {$0.id == product.id}) {
                let param = params.filter({$0.id == product.id})
                if let updateParam = param.first?.dynamicParams {
                    
                    product.updated(with: updateParam)
                }
            }
        }
        
        let productUpdateResult = reduce(products: self.products.value, with: productsList)

        return productUpdateResult
    }
    
    func productForCache(products: [ProductType: [ProductData]]) -> [ProductData] {
        
        var productsData = [ProductData]()
        
        for value in products.values {
            
            for item in value {
                
                guard self.productsAllowed.contains(item.productType) else {
                    break
                }
                
                productsData.append(item)
            }
        }
        
        return productsData
    }
}

enum ModelProductsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
}
