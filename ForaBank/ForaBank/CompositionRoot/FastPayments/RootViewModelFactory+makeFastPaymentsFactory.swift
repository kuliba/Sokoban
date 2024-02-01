//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import FastPaymentsSettings
import Foundation
import UserAccountNavigationComponent

private extension FastPaymentsSettingsServices {
    
#warning("add live services")
    static func live(httpClient: HTTPClient) -> Self {
        
        .init(
            changeConsentList: unimplemented(),
            createContract: unimplemented(),
            updateContract: unimplemented(),
            getC2BSub: unimplemented(),
            getSettings: unimplemented(),
            prepareSetBankDefault: unimplemented(),
            updateProduct: unimplemented()
        )
    }
}

extension RootViewModelFactory {
    
    // TODO: Remove legacy after new one is released
    static func makeFastPaymentsFactory(
        httpClient: HTTPClient,
        model: Model,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag
    ) -> FastPaymentsFactory {
        
        switch fastPaymentsSettingsFlag.rawValue {
        case .active:
            return .init(fastPaymentsViewModel: .new({
                
                makeNewFastPaymentsViewModel(
                    httpClient: httpClient,
                    model: model,
                    scheduler: $0
                )
            }))
            
        case .inactive:
            return .init(
                fastPaymentsViewModel: .legacy({
                    
                    MeToMeSettingView.ViewModel(
                        model: $0,
                        newModel: model,
                        closeAction: $1
                    )
                })
            )
        }
    }
    
    static func makeNewFastPaymentsViewModel(
        useStub isStub: Bool = true,
        httpClient: HTTPClient,
        model: Model,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> FastPaymentsSettingsViewModel {
        
        
        // let f = MicroServices.Factory
        
        let reducer = FastPaymentsSettingsReducer.default(
            getProducts: /*isStub ? { .preview } :*/ model.getProducts
        )
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            services: isStub ? .stub() : .live(httpClient: httpClient)
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

private extension FastPaymentsSettingsReducer {
    
    static func `default`(
        getProducts: @escaping () -> [Product]
    ) -> FastPaymentsSettingsReducer {
        
        let bankDefaultReducer = BankDefaultReducer()
        let consentListReducer = ConsentListRxReducer()
        let contractReducer = ContractReducer(getProducts: getProducts)
        let productsReducer = ProductsReducer(getProducts: getProducts)
        
        return .init(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            consentListReduce: consentListReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
    }
}

private extension FastPaymentsSettingsEffectHandler {
    
    convenience init(
        services: FastPaymentsSettingsServices
    ) {
        let consentListHandler = ConsentListRxEffectHandler(
            changeConsentList: services.changeConsentList
        )
        
        let contractEffectHandler = ContractEffectHandler(
            createContract: services.createContract,
            updateContract: services.updateContract
        )
        
        self.init(
            handleConsentListEffect: consentListHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getC2BSub: services.getC2BSub,
            getSettings: services.getSettings,
            prepareSetBankDefault: services.prepareSetBankDefault,
            updateProduct: services.updateProduct
        )
    }
}

private struct FastPaymentsSettingsServices {
    
    let changeConsentList: ConsentListRxEffectHandler.ChangeConsentList
    let createContract: ContractEffectHandler.CreateContract
    let updateContract: ContractEffectHandler.UpdateContract
    let getC2BSub: FastPaymentsSettingsEffectHandler.GetC2BSub
    let getSettings: FastPaymentsSettingsEffectHandler.GetSettings
    let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefault
    let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProduct
}

// MARK: - Live

private extension Model {
    
#warning("getProducts should employ this requirements for products attributes https://shorturl.at/jtxzS")
#warning("getProducts is expected to sort products in order that would taking first that is `active` and `main`")
    // https://shorturl.at/yTW35
    func getProducts() -> [Product] {
        
        let formatBalance = { [weak self] in
            
            self?.formattedBalance(of: $0) ?? ""
        }
        
        return allProducts.compactMap {
            $0.fastPaymentsProduct(formatBalance: formatBalance)
        }
    }
}

private extension ProductData {
    
    func fastPaymentsProduct(
        formatBalance: @escaping (ProductData) -> String
    ) -> FastPaymentsSettings.Product? {
        
        switch productType {
        case .account:
            guard let account = self as? ProductAccountData,
                  account.status == .active,
                  account.currency == rub
            else { return nil }
            
            return account.fpsProduct(formatBalance: formatBalance)
            
        case .card:
            guard let card = self as? ProductCardData,
                  (card.isMain ?? false),
                  card.status == .active,
                  card.statusPc == .active,
                  card.currency == rub
            else { return nil }
            
            return card.fpsProduct(formatBalance: formatBalance)
            
        default:
            return nil
        }
    }
    
    private var rub: String { "RUB" }
}

private extension ProductAccountData {
    
    func fpsProduct(
        formatBalance: @escaping (ProductData) -> String
    ) -> FastPaymentsSettings.Product {
        
        .init(
            id: .init(id),
            type: .account,
            header: "Счет списания",
            title: displayName,
            number: displayNumber ?? "",
            amountFormatted: formatBalance(self),
            balance: .init(balanceValue),
            look: .init(
                background: .svg(largeDesign.description),
                color: backgroundColor.description,
                icon: .svg(smallDesign.description)
            )
        )
    }
}

private extension ProductCardData {
    
    func fpsProduct(
        formatBalance: @escaping (ProductData) -> String
    ) -> FastPaymentsSettings.Product {
        
        .init(
            id: .init(id),
            type: .card,
            header: "Счет списания",
            title: displayName,
            number: displayNumber ?? "",
            amountFormatted: formatBalance(self),
            balance: .init(balanceValue),
            look: .init(
                background: .svg(largeDesign.description),
                color: backgroundColor.description,
                icon: .svg(smallDesign.description)
            )
        )
    }
}

// MARK: - Stubs

private extension FastPaymentsSettingsServices {
    
    static func stub() -> Self {
        
        let changeConsentList: ConsentListRxEffectHandler.ChangeConsentList = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success)
            }
        }
        
        let createContract: ContractEffectHandler.CreateContract = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(.stub))
            }
        }
        
        let updateContract: ContractEffectHandler.UpdateContract = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(.stub))
            }
        }
        
        let getC2BSub: FastPaymentsSettingsEffectHandler.GetC2BSub = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(.control))
            }
        }
        
        let getSettings: FastPaymentsSettingsEffectHandler.GetSettings = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(.contracted(.init(
                    paymentContract: .stub,
                    consentList: .stub,
                    bankDefaultResponse: .init(bankDefault: .offEnabled),
                    productSelector: .init(
                        selectedProduct: .account,
                        products: .preview
                    )
                ))))
            }
        }
        
        let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefault = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(()))
            }
        }
        
        let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProduct = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(()))
            }
        }
        
        return .init(
            changeConsentList: changeConsentList,
            createContract: createContract,
            updateContract: updateContract,
            getC2BSub: getC2BSub,
            getSettings: getSettings,
            prepareSetBankDefault: prepareSetBankDefault,
            updateProduct: updateProduct
        )
    }
}

private extension UserPaymentSettings.PaymentContract {
    
    static let stub: Self = .init(
        id: 10002076204,
        productID: 10004203497,
        contractStatus: .active,
        phoneNumber: "79171044913",
        phoneNumberMasked: "+7 ... ... 49 13"
    )
}

extension ConsentListState {
    
    static let stub: Self = .success(.init(
        banks: .preview,
        consent: .preview,
        mode: .collapsed,
        searchText: ""
    ))
}
