//
//  Model+Products.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation
import CloudKit

//MARK: - Actions

typealias ProductsData = [ProductType : [ProductData]]
typealias ProductsDynamicParams = [ServerCommands.ProductController.GetProductDynamicParamsList.Response.List.DynamicListParams]
typealias LoansData = [PersonsCreditData]

//MARK: - Helpers

extension Model {
    
    var productsOpenAccountURL: URL { URL(string: "https://promo.forabank.ru/")! }
    
    func product(productId: ProductData.ID) -> ProductData? {
        
        products.value.values.flatMap({ $0 }).first(where: { $0.id == productId })
    }
}

//MARK: - Action

extension ModelAction {
    
    enum Products {
        
        enum Update {
            
            enum Fast {
                
                struct All: Action {}
                
                enum Single {
                    
                    struct Request: Action {
                        
                        let productId: ProductData.ID
                    }
                    
                    struct Response: Action {
                        
                        let productId: ProductData.ID
                        let result: Result<ProductDynamicParamsData, Error>
                    }
                }
            }
            
            enum Total {
                
                struct All: Action {}
            }

            struct ForProductType: Action {

                let productType: ProductType
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

        enum ActivateCard {

            struct Request: Action {

                let cardID: ProductData.ID
                let cardNumber: String
            }

            enum Response: Action {

                case complete
                case failed(message: String)
            }
        }
        
        enum ProductDetails {
            
            struct Request: Action {
                            
               let type: ProductType
               let id: ProductData.ID
            }
            
            enum Response: Action {
                
                case success(productDetails: ProductDetailsData)
                case failure(message: String)
            }
        }
        
        enum StatementPrintForm {
            
            struct Request: Action {
                
                let productId: ProductData.ID
                let startDate: Date
                let endDate: Date
            }
            
            struct Response: Action {
                
                let result: Result<Data, Error>
            }
        }
        
        enum DepositConditionsPrintForm {
       
            struct Request: Action {
                
                let depositId: ProductData.ID
            }
            
            struct Response: Action {
                
                let result: Result<Data, Error>
            }
        }
    }
    
    enum Loans {
        
        enum Update {
       
            struct All: Action {}
            
            enum Single {
                
                struct Request: Action {
                    
                    let productId: ProductData.ID
                }
                
                struct Response: Action {
                    
                    let productId: ProductData.ID
                    let result: Result<PersonsCreditData, Error>
                }
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
        productsFastUpdating.value = Set(productsList.map{ $0.id })
        
        let command = ServerCommands.ProductController.GetProductDynamicParamsList(token: token, products: productsList)
        
        serverAgent.executeCommand(command: command) { result in
            
            self.productsFastUpdating.value = []
            
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
        
        guard productsFastUpdating.value.contains(payload.productId) == false else {
            return
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard let product = products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId }),
              let command = createCommand(productId: product.id, productType: product.productType) else {
            return
        }
        
        productsFastUpdating.value.insert(product.id)

        serverAgent.executeCommand(command: command) { result in
            
            self.productsFastUpdating.value.remove(product.id)
            
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
        
        func createCommand(productId: ProductData.ID, productType: ProductType) -> ServerCommands.ProductController.GetProductDynamicParams? {
            
            switch productType {
            case .card:
                
                let command = ServerCommands.ProductController.GetProductDynamicParams(token: token, payload: .init(accountId: nil, cardId: productId.description, depositId: nil))
                return command
                
            case .account:
                
                let command = ServerCommands.ProductController.GetProductDynamicParams(token: token, payload: .init(accountId: productId.description, cardId: nil, depositId: nil))
                return command
                
            case .deposit:
                
                let command = ServerCommands.ProductController.GetProductDynamicParams(token: token, payload: .init(accountId: nil, cardId: nil, depositId: productId.description))
                return command
                
            case .loan:
                return nil
            }
        }
    }

    func handleProductsUpdateTotalAll() {
        
        guard self.productsUpdating.value.isEmpty == true else {
            return
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
            
            self.productsUpdating.value = Array(productsAllowed)
            
            for productType in ProductType.allCases {
                
                guard productsAllowed.contains(productType) else {
                    continue
                }

                let serial = productsCacheSerial(for: productType)
                let command = ServerCommands.ProductController.GetProductListByType(token: token, serial: serial, productType: productType)
                             
                do {
                    
                    let result = try await productsFetchWithCommand(command: command)
  
                    // updating status
                    if let index = self.productsUpdating.value.firstIndex(of: productType) {
                        
                        self.productsUpdating.value.remove(at: index)
                    }
                    
                    guard result.products.isEmpty == false else {
                        continue
                    }
                    
                    // cache products
                    try productsCaheData(products: result.products, serial: result.serial)

                    // update products
                    self.products.value = reduce(products: self.products.value, with: result.products, allowed: self.productsAllowed)
                    
                    // update loans data
                    if productType == .loan {
                        
                        self.action.send(ModelAction.Loans.Update.All())
                    }

                } catch {
                    
                    // updating status
                    if let index = self.productsUpdating.value.firstIndex(of: productType) {
                        
                        self.productsUpdating.value.remove(at: index)
                    }
                    
                    self.handleServerCommandError(error: error, command: command)
                    //TODO: show error message in UI
                }
            }
        }
    }

    func handleProductsUpdateTotalProduct(_ product: ModelAction.Products.Update.ForProductType) {

        guard productsUpdating.value.contains(product.productType) == false,
              productsAllowed.contains(product.productType) == true else {
                  return
              }

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        Task {

            self.productsUpdating.value.append(product.productType)

            let serial = productsCacheSerial(for: product.productType)
            let command = ServerCommands.ProductController.GetProductListByType(token: token, serial: serial, productType: product.productType)

            do {

                let result = try await productsFetchWithCommand(command: command)

                // updating status
                if let index = self.productsUpdating.value.firstIndex(of: product.productType) {

                    self.productsUpdating.value.remove(at: index)
                }

                guard result.products.isEmpty == false else {
                    return
                }

                // cache products
                try productsCaheData(products: result.products, serial: result.serial)

                // update products
                self.products.value = reduce(products: self.products.value, with: result.products, allowed: self.productsAllowed)

                // update loans data
                if product.productType == .loan {

                    self.action.send(ModelAction.Loans.Update.All())
                }

            } catch {

                // updating status
                if let index = self.productsUpdating.value.firstIndex(of: product.productType) {

                    self.productsUpdating.value.remove(at: index)
                }

                self.handleServerCommandError(error: error, command: command)
                //TODO: show error message in UI
            }
        }
    }

    func handleProductsActivateCard(_ payload: ModelAction.Products.ActivateCard.Request) {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let id = payload.cardID
        let number = payload.cardNumber
        let defaultErrorMessage = "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."

        let command = ServerCommands.CardController.UnblockCard(token: token, payload: .init(cardID: id, cardNumber: number))

        serverAgent.executeCommand(command: command) { result in

            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:

                    guard response.data != nil else {

                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Products.ActivateCard.Response.failed(message: defaultErrorMessage))

                        return
                    }

                    self.products.value = Model.reduce(products: self.products.value, cardID: id)

                    do {

                        try self.localAgent.store(self.products.value, serial: nil)

                    } catch {

                        self.handleServerCommandCachingError(error: error, command: command)
                    }

                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.Products.ActivateCard.Response.failed(message: response.errorMessage ?? defaultErrorMessage))
                }

            case let .failure(error):
                self.action.send(ModelAction.Products.ActivateCard.Response.failed(message: error.localizedDescription))
            }
        }
    }
    
    func productsFetchWithCommand(command: ServerCommands.ProductController.GetProductListByType) async throws -> (products: [ProductData], serial: String) {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let data = response.data else {
                            continuation.resume(with: .failure(ModelProductsError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: (data.productList, data.serial))

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
            let command = ServerCommands.CardController.SaveCardName(token: token, productId: id, name: name)
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
            let command = ServerCommands.AccountController.SaveAccountName(token: token, productId: id, name: name)
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
            let command = ServerCommands.DepositController.SaveDepositName(token: token, productId: id, name: name)
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
    
    func handleProductsUpdateCustomNameResponse(_ payload: ModelAction.Products.UpdateCustomName.Response) {
        
        switch payload {
        case .complete(productId: let productId, name: _):
            self.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productId))
            
        default: break
        }
    }
    
    func handleProductDetails(_ payload: ModelAction.Products.ProductDetails.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        var command = ServerCommands.ProductController.GetProductDetails(token: token, payload: .init(accountId: nil, cardId: nil, depositId: nil))
        
        switch payload.type {
        case .card:
            command = ServerCommands.ProductController.GetProductDetails(token: token, payload: .init(accountId: nil, cardId: payload.id, depositId: nil))
        case .deposit:
            command = ServerCommands.ProductController.GetProductDetails(token: token, payload: .init(accountId: nil, cardId: nil, depositId: payload.id))
        case .account:
            command = ServerCommands.ProductController.GetProductDetails(token: token, payload: .init(accountId: payload.id, cardId: nil, depositId: nil))
        case .loan:
            guard let product = self.products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.id }), let product = product as? ProductLoanData else {
                return
            }
            
            command = ServerCommands.ProductController.GetProductDetails(token: token, payload: .init(accountId: product.settlementAccountId, cardId: nil, depositId: nil))
        }
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let details = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.action.send(ModelAction.Products.ProductDetails.Response.success(productDetails: details))
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleProductsStatementPrintFormRequest(_ payload: ModelAction.Products.StatementPrintForm.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard let product = products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId}) else {
            return
        }
        
        switch product {
        case let cardProduct as ProductCardData:
            let command = ServerCommands.CardController.GetPrintFormForCardStatement(token: token, payload: .init(id: cardProduct.id, startDate: payload.startDate, endDate: payload.endDate))
            serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
                
                switch result {
                case .success(let data):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .success(data)))
                    
                case .failure(let error):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .failure(error)))
                }
            }
            
        case let accountProduct as ProductAccountData:
            let command = ServerCommands.AccountController.GetPrintFormForAccountStatement(token: token, payload: .init(id: accountProduct.id, startDate: payload.startDate, endDate: payload.endDate))
            serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
                
                switch result {
                case .success(let data):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .success(data)))
                    
                case .failure(let error):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .failure(error)))
                }
            }
            
        case let depositProduct as ProductDepositData:
            let command = ServerCommands.AccountController.GetPrintFormForAccountStatement(token: token, payload: .init(id: depositProduct.accountId, startDate: payload.startDate, endDate: payload.endDate))
            serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
                
                switch result {
                case .success(let data):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .success(data)))
                    
                case .failure(let error):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .failure(error)))
                }
            }
            
        case let loanProduct as ProductLoanData:
            let command = ServerCommands.AccountController.GetPrintFormForAccountStatement(token: token, payload: .init(id: loanProduct.settlementAccountId, startDate: payload.startDate, endDate: payload.endDate))
            serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
                
                switch result {
                case .success(let data):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .success(data)))
                    
                case .failure(let error):
                    action.send(ModelAction.Products.StatementPrintForm.Response(result: .failure(error)))
                }
            }
            
        default:
            return
        }
    }
    
    func handleProductsDepositConditionPrintFormRequest(_ payload: ModelAction.Products.DepositConditionsPrintForm.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.GetPrintFormForDepositConditions(token: token, depositId: payload.depositId)
        serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                action.send(ModelAction.Products.DepositConditionsPrintForm.Response(result: .success(data)))
                
            case .failure(let error):
                action.send(ModelAction.Products.DepositConditionsPrintForm.Response(result: .failure(error)))
            }
        }
    }
}

//MARK: - Loans

extension Model {
    
    func handleLoansUpdateAllRequest() {
        
        guard let loanProducts = products.value[.loan], loanProducts.isEmpty == false else {
            return
        }
        
        for loan in loanProducts {
            
            action.send(ModelAction.Loans.Update.Single.Request(productId: loan.id))
        }
    }
    
    func handleLoansUpdateSingleRequest(_ payload: ModelAction.Loans.Update.Single.Request) {
        
        guard loansUpdating.value.contains(payload.productId) == false else {
            return
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
            
            let command = ServerCommands.LoanController.GetPersonsCredit(token: token, payload: .init(id: payload.productId))
            
            do {
                
                self.loansUpdating.value.insert(payload.productId)
                
                let result = try await loansFetchWithCommand(command: command)
                
                self.loansUpdating.value.remove(payload.productId)
                self.loans.value = reduce(loans: self.loans.value, personsCreditData: result.original, productId: payload.productId)
                
                
                //TODO: update loan product's custom name with result.customName?
                
                do {
                    
                    try localAgent.store(self.loans.value, serial: nil)
                    
                } catch {
                    
                    print("Model: handleLoansUpdateSingleRequest: caching LoansData error: \(error)")
                }

            } catch {
                
                self.loansUpdating.value.remove(payload.productId)
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Loans.Update.Single.Response(productId: payload.productId, result: .failure(error)))
            }
        }
    }
   
    func loansFetchWithCommand(command: ServerCommands.LoanController.GetPersonsCredit) async throws -> ServerCommands.LoanController.GetPersonsCredit.Response.ResultData {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let data = response.data else {
                            continuation.resume(with: .failure(ModelProductsError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: data)

                    default:
                        continuation.resume(with: .failure(ModelProductsError.statusError(status: response.statusCode, message: response.errorMessage)))
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(ModelProductsError.serverCommandError(error: error.localizedDescription)))
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

    /// Activate card for products
    static func reduce(products: ProductsData, cardID: ProductData.ID) -> ProductsData {

        guard let productCards = products[.card],
              let productCard = productCards.first(where: { $0.id == cardID }) as? ProductCardData else {
            return products
        }

        productCard.status = .active
        productCard.statusPc = .active

        return products
    }
    
    func reduce(loans: LoansData, personsCreditData: PersonsCreditData, productId: ProductData.ID) -> LoansData {

        if loans.contains(where: { $0.loandId == productId}) {
            
            var updated = LoansData()
            
            for item in loans {
                
                if item.loandId == productId {
                    
                    updated.append(personsCreditData)
                    
                } else {
                    
                    updated.append(item)
                }
            }
            
            return updated
            
        } else {
            
            var updated = loans
            updated.append(personsCreditData)
            
            return updated
        }
    }
}

//MARK: - Cache

extension Model {
    
    func productsCaheData(products: [ProductData], serial: String?) throws {
        
        if let cards = products as? [ProductCardData] {
            
            try localAgent.store(cards, serial: serial)
            
        } else if let accounts = products as? [ProductAccountData] {
            
            try localAgent.store(accounts, serial: serial)
            
        } else if let deposits = products as? [ProductDepositData] {
            
            try localAgent.store(deposits, serial: serial)
            
        } else if let loans = products as? [ProductLoanData] {
            
            try localAgent.store(loans, serial: serial)
            
        } else {
            
            throw ModelProductsError.unableCacheUnknownProductType
        }
    }
    
    func productsCacheLoadData() -> ProductsData {
        
        var result = ProductsData()
        
        for productType in ProductType.allCases {
            
            switch productType {
            case .card:
                result[.card] = localAgent.load(type: [ProductCardData].self)
                
            case .account:
                result[.account] = localAgent.load(type: [ProductAccountData].self)
                
            case .deposit:
                result[.deposit] = localAgent.load(type: [ProductDepositData].self)
                
            case .loan:
                result[.loan] = localAgent.load(type: [ProductLoanData].self)
            }
        }
        
        return result
    }
    
    func productsCacheClearData() throws  {
        
        var errors = [Error]()
        
        for productType in ProductType.allCases {
            
            do {
                
                switch productType {
                case .card:
                    try localAgent.clear(type: [ProductCardData].self)
                    
                case .account:
                    try localAgent.clear(type: [ProductAccountData].self)
                    
                case .deposit:
                    try localAgent.clear(type: [ProductDepositData].self)
                    
                case .loan:
                    try localAgent.clear(type: [ProductLoanData].self)
                }
                
            } catch {
                
                errors.append(error)
            }
        }
        
        if errors.isEmpty == false {
            
            throw ModelProductsError.clearCacheErrors(errors)
        }
    }
    
    func productsCacheSerial(for type: ProductType) -> String? {
        
        switch type {
        case .card:
            return localAgent.serial(for: [ProductCardData].self)
            
        case .account:
            return localAgent.serial(for: [ProductAccountData].self)
            
        case .deposit:
            return localAgent.serial(for: [ProductDepositData].self)
            
        case .loan:
            return localAgent.serial(for: [ProductLoanData].self)
        }
    }
}

//MARK: - Error

enum ModelProductsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
    case unableCacheUnknownProductType
    case clearCacheErrors([Error])
}
