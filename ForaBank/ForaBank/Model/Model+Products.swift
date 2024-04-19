//
//  Model+Products.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import CloudKit
import Foundation
import ServerAgent
import CardStatementAPI
import AccountInfoPanel

//MARK: - Actions

typealias ProductsData = [ProductType : [ProductData]]
typealias ProductsDynamicParams = CardStatementAPI.DynamicParamsList
typealias LoansData = [PersonsCreditData]

//MARK: - Helpers

extension Model {
    
    var productsOpenAccountURL: URL { URL(string: "https://promo2.forabank.ru/")! }
    var productsOpenLoanURL: URL { URL(string: "https://www.forabank.ru/private/credits/")! }
    var productsOpenInsuranceURL: URL { URL(string: "https://www.forabank.ru/landings/e-osago/")! }
    var productsOpenMortgageURL: URL { URL(string: "https://www.forabank.ru/private/mortgage/")! }
        
    var allProducts: [ProductData] {
        
        // получили все продукты
        let currentProducts = products.value.values.flatMap{ $0 }
        
        // сгруппировали карты по idParent
        let dictionary = currentProducts.groupingByParentID()
        
        var all: [ProductData] = []
        
        currentProducts.forEach { product in
            // группируем карты главная + ее допки
            if let values = dictionary[product.id] {
                // добавляем главную
                all.append(product)
                // добавляем ее допки
                all.append(contentsOf: values)
            } else if product.asCard?.idParent == nil { // исключаем повторное добавление допок
                all.append(product)
            }
        }
        
        // добавляем допки, которые выпущены не владельцем (главной карты на текущем аккаунте нет)
        let allIDs = all.map(\.id)
        dictionary.forEach {
            // если на аккаунте нет такой карточки - добавляем все ее допки
            if !allIDs.contains($0) {
                all.append(contentsOf: $1)
            }
        }
        // сортируем по типу продуктов
        return all.sorted(by: \.productType.order)
    }
    
    func productType(for productId: ProductData.ID) -> ProductType? {
        
        allProducts.first(where: { $0.id == productId })?.productType
    }
    
    func firstProduct(with filter: ProductData.Filter) -> ProductData? {
        
        if let preferredProductID {
            
            let filteredProducts = filter.filteredProducts(allProducts)
            let preferedProduct = filteredProducts.first(where: { $0.id == preferredProductID })
            
            return preferedProduct ?? filteredProducts.first

        } else {
            
            return filter.filteredProducts(allProducts).first
        }
    }
    
    var isAllProductsHidden: Bool {
        products.value.values
            .flatMap { $0 }
            .filter { $0.isVisible }
            .isEmpty
    }
    
    var productsTypes: [ProductType] {
        
        products.value.keys.map {$0}
    }
    
    func product() -> ProductData? {
        
        products.value.values.flatMap {$0}.sorted { $0.productType.order < $1.productType.order }.first
    }
    
    func product(productId: ProductData.ID) -> ProductData? {
        
        allProducts.first(where: { $0.id == productId })
    }
    
    func product(additionalId: ProductData.ID) -> ProductData? {
        
        products.value.values.flatMap({ $0 }).first(where: { $0.additionalAccountId == additionalId })
    }
    
    func allProductsCurrency() -> [Currency] {
        
        var uniqueCurrency: [Currency] = []
        
        let allProductsCurrency = allProducts.compactMap { $0.currency }
        let uniqueProductsCurrency = Set(allProductsCurrency)
        
        uniqueCurrency = uniqueProductsCurrency.map(Currency.init)
        
        return uniqueCurrency
    }
    
    func products(_ productType: ProductType) -> [ProductData]? {
        
        products.value[productType]
    }
    
    func firstProductId(currency: Currency) -> ProductData.ID? {
        
        let product = allProducts.first(where: { $0.currency == currency.description })
        
        guard let product = product else {
            return nil
        }
        
        return product.id
    }
    
    func products(currency: Currency, currencyOperation: CurrencyOperation, productType: ProductType) -> [ProductData] {
        
        var products: [ProductData] = []
        
        guard let productTypes = self.products.value[productType] else {
            return products
        }
        
        products = filteredProducts(currency: currency, currencyOperation: currencyOperation, products: productTypes)

        return products
    }
    
    func products(products: ProductsData, currency: Currency, currencyOperation: CurrencyOperation) -> [ProductData] {

        filteredProducts(currency: currency, currencyOperation: currencyOperation, products: allProducts)
    }
    
    func products(currency: Currency, currencyOperation: CurrencyOperation) -> [ProductData] {
        
        return filteredProducts(currency: currency, currencyOperation: currencyOperation, products: allProducts)
    }
    
    func products(currency: Currency) -> [ProductData] {
        
        let clientId = Model.shared.clientInfo.value?.id
        let products = products.value.values
            .flatMap { $0 }
            .filter {
                $0.ownerId == clientId && $0.currency == currency.description
            }
        
        return products
    }
    
    func products(currency: Currency, currencyOperation: CurrencyOperation, products: ProductsData) -> [ProductData] {
        
        return filteredProducts(currency: currency, currencyOperation: currencyOperation, products: allProducts)
    }
    
    private func filteredProducts(currency: Currency, currencyOperation: CurrencyOperation, products: [ProductData]) -> [ProductData] {
        
        let products = products.filter { product in
            
            switch product.productType {
            case .card:
                
                guard let product = product as? ProductCardData else {
                    return false
                }
                
                if let loanBaseParam = product.loanBaseParam, product.isMain == false {
                    
                    return product.currency == currency.description && product.status == .active && product.statusPc == .active && loanBaseParam.clientId == product.ownerId && product.isAccountNumber && product.allowProduct(currencyOperation)
                    
                } else {
                    
                    return product.currency == currency.description && product.status == .active && product.statusPc == .active && product.isAccountNumber && product.allowProduct(currencyOperation)
                }
                
            case .account:
                
                guard let product = product as? ProductAccountData else {
                    return false
                }
                
                return product.currency == currency.description && product.status == .notBlocked && product.isAccountNumber && product.allowProduct(currencyOperation)
                
            case .deposit:
                
                guard let product = product as? ProductDepositData else {
                    return false
                }
                
                return product.currency == currency.description && product.isDemandDeposit && product.allowProduct(currencyOperation)
                
            case .loan:
                return false
            }
        }
        
        return products
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
                
                case success(productDetails: AccountInfoPanel.ProductDetails)
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
        
        struct UpdateVisibility: Action {
            
            let productId: ProductData.ID
            let visibility: Bool
        }
        
        struct UpdateOrders: Action {
            
            let orders: [ProductType: [ProductData.ID]]
        }
        
        enum ContractPrintForm {
       
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

private extension ProductType {
    
    var typeValueForRequest: ProductDynamicParamsListPayload.ProductType {
        
        switch self {
        case .card:
            return .card
        case .account:
            return .account
        case .deposit:
            return .deposit
        case .loan:
            return .loan
        }
    }
}

extension Model {
    
    func handleProductsUpdateFastAll() {
        Task { try? await handleProductsUpdateFastAllAsync() }
    }
    
    func handleProductsUpdateFastAllAsync() async throws {
        
        let productsList = products.value.values.flatMap{ $0 }
        productsFastUpdating.value = Set(productsList.map{ $0.id })
        
        let payload: ProductDynamicParamsListPayload = .init(productList: productsList.map { .init(productId: .init($0.id), type: $0.productType.typeValueForRequest)})
        
        let params = try await Services.makeGetProductDynamicParamsList(
            httpClient: self.authenticatedHTTPClient(),
            logger: LoggerAgent.shared,
            payload: payload
        )
        self.productsFastUpdating.value = []
        let updatedProducts = Self.reduce(products: self.products.value, with: params)
        self.products.value = updatedProducts
        
        // cache products
        try self.productsCacheStore(productsData: updatedProducts)
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
                    
                    // update products
                    let updatedProducts = Self.reduce(products: self.products.value, with: params, productId: payload.productId)
                    self.products.value = updatedProducts
                    
                    // cache products
                    do {
                        
                        try self.productsCacheStore(productsData: updatedProducts)
                        
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
                
                let command = ServerCommands.ProductController.GetProductListByType(token: token, productType: productType)
                updateProduct(command, productType: productType)
            }
        }
    }
    
    func handleProductsUpdateTotalProduct(_ payload: ModelAction.Products.Update.ForProductType) {

        guard productsUpdating.value.contains(payload.productType) == false,
              productsAllowed.contains(payload.productType) == true else {
                  return
              }

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        Task {

            self.productsUpdating.value.append(payload.productType)

            let command = ServerCommands.ProductController.GetProductListByType(token: token, productType: payload.productType)

            updateProduct(command, productType: payload.productType)
        }
    }
    
    func updateProduct(_ command: ServerCommands.ProductController.GetProductListByType, productType: ProductType) {
        
        getProducts(productType) { response in
            
            if let response {
                
                let result = Services.mapProductResponse(response)
                
                if let index = self.productsUpdating.value.firstIndex(of: productType) {
                    
                    self.productsUpdating.value.remove(at: index)
                }
                
                // update products
                let updatedProducts = Self.reduce(products: self.products.value, with: result.productList, for: productType)
                self.products.value = updatedProducts
                
                //md5hash -> image
                let md5Products = result.productList.reduce(Set<String>(), {
                    $0.union([$1.smallDesignMd5hash,
                              $1.smallBackgroundDesignHash,
                              $1.xlDesignMd5Hash,
                              $1.largeDesignMd5Hash,
                              $1.mediumDesignMd5Hash,
                              $1.paymentSystemMd5Hash
                             ]) })
                
                let md5ToUpload = Array(md5Products.subtracting(self.images.value.keys))
                if !md5ToUpload.isEmpty {
                    self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: md5ToUpload ))
                }
                
                // cache products
                do {
                    
                    try self.productsCacheStore(productsData: updatedProducts)
                    
                } catch {
                    
                    self.handleServerCommandCachingError(error: error, command: command)
                }
                
                // update additional products data
                switch productType {
                case .deposit:
                    self.action.send(ModelAction.Deposits.Info.All())
                    
                case .loan:
                    self.action.send(ModelAction.Loans.Update.All())
                    
                default:
                    break
                }
            }
        }
    }
    
    func handleProductsUpdateVisibility(_ payload: ModelAction.Products.UpdateVisibility) {
        
        guard !productsVisibilityUpdating.value.contains(payload.productId) else { return }
        
        guard let token = token
        else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
                
            guard let product = self.product(productId: payload.productId) else { return }
            
            let command = ServerCommands.ProductController
                                        .UserVisibilityProductsSettings(token: token,
                                                                        productType: product.productType,
                                                                        productId: product.id,
                                                                        visibility: payload.visibility)
            self.productsVisibilityUpdating.value.insert(product.id)
          
            do {
                
                let _ = try await productsSetSettingsWithCommand(command: command)
                    
                self.productsVisibilityUpdating.value.remove(product.id)
                    
                // update products
                let updatedProducts = Self.reduce(
                    productsData: self.products.value,
                    productId: payload.productId,
                    isVisible: payload.visibility)
                self.products.value = updatedProducts
                    
                do { // update cache
                        
                    try self.productsCacheStore(productsData: updatedProducts) //productsCaheData(productsData: updatedProducts)
                        
                } catch {
                        
                    self.handleServerCommandCachingError(error: error, command: command)
                }

            } catch {
                    
                self.productsVisibilityUpdating.value.remove(product.id)
                self.handleServerCommandError(error: error, command: command)
            }
        }
        
    }
    
    func handleProductsUpdateOrders(_ payload: ModelAction.Products.UpdateOrders) {
        
        guard !productsOrdersUpdating.value else { return }
        
        guard let token = token
        else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
            
            let command = ServerCommands.ProductController
                            .UserOrdersProductsSettings(token: token, newOrders: payload.orders)
            
            self.productsOrdersUpdating.value = true
          
            do {
                
                let _ = try await productsSetSettingsWithCommand(command: command)
                    
                self.productsOrdersUpdating.value = false
                
                // update products
                let updatedProducts = Self.reduce(productsData: self.products.value, newOrders: payload.orders)
                                                      
                self.products.value = updatedProducts
                    
                do { // update cache
                        
                    try self.productsCacheStore(productsData: updatedProducts)
                        
                } catch {
                     
                    self.handleServerCommandCachingError(error: error, command: command)
                }

            } catch {
                    
                self.productsOrdersUpdating.value = false
                self.handleServerCommandError(error: error, command: command)
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

                    let updatedProducts = Model.reduce(products: self.products.value, cardID: id)
                    self.products.value = updatedProducts

                    // cache products
                    do {
                        
                        try self.productsCacheStore(productsData: updatedProducts)
                        
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
    
    func productsSetSettingsWithCommand<Command: ServerCommand>(command: Command) async throws -> Bool {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        continuation.resume(returning: true)

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
        Task {
            
            if let productDetails = try? await handleProductDetailsAsync(payload) {
                
                if !productDetails.infoMd5hash.isEmpty {
                    
                    if self.images.value[productDetails.infoMd5hash] == nil {
                        self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [productDetails.infoMd5hash] ))
                    }
                }
                
                self.action.send(ModelAction.Products.ProductDetails.Response.success(productDetails: productDetails))
            }
        }
    }
    
    func handleProductDetailsAsync(_ payload: ModelAction.Products.ProductDetails.Request) async throws -> ProductDetails? {
        
        let productDetailsPayload: ProductDetailsPayload

        switch payload.type {
        case .card:
            productDetailsPayload = .cardId(.init(payload.id))
        case .deposit:
            productDetailsPayload = .depositId(.init(payload.id))
        case .account:
            productDetailsPayload = .accountId(.init(payload.id))
        case .loan:
            guard let product = self.products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.id }), let product = product as? ProductLoanData else {
                return .none
            }
            productDetailsPayload = .accountId(.init(product.settlementAccountId))
        }

        return try await Services.makeGetProductDetails(
            httpClient: self.authenticatedHTTPClient(),
            logger: LoggerAgent.shared,
            payload: productDetailsPayload
        )
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
    
    func handleProductsContractPrintFormRequest(_ payload: ModelAction.Products.ContractPrintForm.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DepositController.GetPrintFormForDepositAgreement(token: token, depositId: payload.depositId)
        serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                action.send(ModelAction.Products.ContractPrintForm.Response(result: .success(data)))
                
            case .failure(let error):
                action.send(ModelAction.Products.ContractPrintForm.Response(result: .failure(error)))
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
                self.loans.value = Self.reduce(loans: self.loans.value, personsCreditData: result.original, productId: payload.productId)
                
                //TODO: update loan product's custom name with result.customName?
                
                do {
                    
                    try localAgent.store(self.loans.value, serial: nil)
                    
                } catch {
                    
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

extension Model {
    
    /// Products data
    static func reduce(products: ProductsData, with productsList: [ProductData], for type: ProductType) -> ProductsData {
        
        func isCorrect(type: ProductType, for productsList: [ProductData]) -> Bool {
            
            switch type {
            case .card:
                return productsList is [ProductCardData]
                
            case .account:
                return productsList is [ProductAccountData]
                
            case .deposit:
                return productsList is [ProductDepositData]
                
            case .loan:
                return productsList is [ProductLoanData]
            }
        }
        
        var result = products
        
        if productsList.isEmpty == false {
            
            guard isCorrect(type: type, for: productsList) else {
                return products
            }
            
            result[type] = productsList
            
        } else {
            
            result[type] = nil
        }
        
        return result
    }
    
    /// Dynamic parameter
    static func reduce(products: ProductsData, with params: ProductDynamicParamsData, productId: Int) -> ProductsData {
        
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
    
    /// Dynamic parameters
    static func reduce(products: ProductsData, with params: ProductsDynamicParams) -> ProductsData {
        
        var productsUpdated = ProductsData()
        
        for productType in products.keys {
            
            guard let productsForType = products[productType] else {
                continue
            }
            
            var productsForTypeUpdated = [ProductData]()
            
            for product in productsForType {
                
                if let dynamicParam = params.list.first(where: { $0.id == product.id })?.dynamicParams {
                    
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

        productCard.activate()

        return products
    }
    
    //TODO: tests
    /// Loans data
    static func reduce(loans: LoansData, personsCreditData: PersonsCreditData, productId: ProductData.ID) -> LoansData {

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
    
    static func reduce(productsData: ProductsData, productId: ProductData.ID, isVisible: Bool) -> ProductsData {
        
        let product = productsData.values.flatMap({ $0 }).first(where: { $0.id == productId })
        
        product?.update(isVisible: isVisible)
        
        return productsData
    }
    
    static func reduce(productsData: ProductsData, newOrders: [ProductType: [ProductData.ID]])  -> ProductsData {
            
            var productsUpdated = ProductsData()
            
            for productType in ProductType.allCases {
                
                guard var productsForType = productsData[productType] else { continue }
                
                if let productsIdsNewOrder = newOrders[productType]  {
                    
                    let productsForTypeIdsSet = Set(productsForType.map { $0.id })
                    let productsIdsNewOrderSet = Set(productsIdsNewOrder)
                    
                    guard productsForTypeIdsSet == productsIdsNewOrderSet
                    else { return productsData }
                    
                    for (index, productId) in productsIdsNewOrder.enumerated() {
                        
                        if let product = productsForType.first(where: { $0.id == productId }) {
                            
                            product.update(order: index)
                        }
                    }
                    
                    productsForType.sort(by: {$1.order > $0.order })
                }
                
                productsUpdated[productType] = productsForType
            } 
            
            return productsUpdated
        }
    
}

//MARK: - Cache

extension Model {
    
    func productsCacheStore(productsData: ProductsData) throws {
        
        var errors = [Error]()
        
        for type in ProductType.allCases {
        
            switch type {
            case .card:
                if let cardProducts = productsData[.card] as? [ProductCardData] {
                    
                    do {
                    
                        try localAgent.store(cardProducts, serial: nil)
                        
                    } catch {
                        
                        errors.append(error)
                    }
                    
                } else {
                    
                    do {
                        
                        try localAgent.clear(type: [ProductCardData].self)
    
                    } catch {
                        
                        errors.append(error)
                    }
                }
            
            case .account:
                if let accountProducts = productsData[.account] as? [ProductAccountData] {
                    
                    do {
                    
                        try localAgent.store(accountProducts, serial: nil)
                        
                    } catch {
                        
                        errors.append(error)
                    }
                    
                } else {
                    
                    do {
                        
                        try localAgent.clear(type: [ProductAccountData].self)
    
                    } catch {
                        
                        errors.append(error)
                    }
                }
                
            case .deposit:
                if let depositProducts = productsData[.deposit] as? [ProductDepositData] {
                    
                    do {
                    
                        try localAgent.store(depositProducts, serial: nil)
                        
                    } catch {
                        
                        errors.append(error)
                    }
                    
                } else {
                    
                    do {
                        
                        try localAgent.clear(type: [ProductDepositData].self)
    
                    } catch {
                        
                        errors.append(error)
                    }
                }
                
            case .loan:
                if let loanProducts = productsData[type] as? [ProductLoanData] {
                    
                    do {
                    
                        try localAgent.store(loanProducts, serial: nil)
                        
                    } catch {
                        
                        errors.append(error)
                    }
                    
                } else {
                    
                    do {
                        
                        try localAgent.clear(type: [ProductLoanData].self)
    
                    } catch {
                        
                        errors.append(error)
                    }
                }
            }
        }
        
        if errors.isEmpty == false {
            
            throw ModelProductsError.cacheStoreErrors(errors)
        }
    }
    
    func productsCacheLoad() -> ProductsData {
        
        var productsData = ProductsData()
        
        for type in ProductType.allCases {
            
            switch type {
            case .card:
                productsData[.card] = localAgent.load(type: [ProductCardData].self)
                
            case .account:
                productsData[.account] = localAgent.load(type: [ProductAccountData].self)
                
            case .deposit:
                productsData[.deposit] = localAgent.load(type: [ProductDepositData].self)
                
            case .loan:
                productsData[.loan] = localAgent.load(type: [ProductLoanData].self)
            }
        }
        
        return productsData
    }
    
    func productsCacheClear() throws  {
        
        var errors = [Error]()
        
        for type in ProductType.allCases {
            
            switch type {
            case .card:
                do {
                    
                    try localAgent.clear(type: [ProductCardData].self)
                    
                } catch {
                    
                    errors.append(error)
                }
                
            case .account:
                do {
                    
                    try localAgent.clear(type: [ProductAccountData].self)
                    
                } catch {
                    
                    errors.append(error)
                }
                
            case .deposit:
                do {
                    
                    try localAgent.clear(type: [ProductDepositData].self)
                    
                } catch {
                    
                    errors.append(error)
                }
                
            case .loan:
                do {
                    
                    try localAgent.clear(type: [ProductLoanData].self)
                    
                } catch {
                    
                    errors.append(error)
                }
            }
        }
        
        if errors.isEmpty == false {
            
            throw ModelProductsError.cacheClearErrors(errors)
        }
    }
}

//MARK: - Error

enum ModelProductsError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
    case unableCacheUnknownProductType
    case cacheStoreErrors([Error])
    case cacheClearErrors([Error])
}
