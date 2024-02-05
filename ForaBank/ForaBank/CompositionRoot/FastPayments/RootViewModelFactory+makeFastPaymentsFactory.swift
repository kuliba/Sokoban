//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import FastPaymentsSettings
import Foundation
import UserAccountNavigationComponent

private extension Model {
    
#warning("add mapping and filtering products from model")
    func getProducts() -> [Product] {
        
        unimplemented()
    }
}

private extension FastPaymentsSettingsServices {
    
#warning("add live services")
    static func live(httpClient: HTTPClient) -> Self {
        
        .init(
            handleConsentListEffect: unimplemented(),
            handleContractEffect: unimplemented(),
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
        
        let reducer = FastPaymentsSettingsReducer.default(
            getProducts: isStub ? { .preview } : model.getProducts
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
        self.init(
            handleConsentListEffect: services.handleConsentListEffect,
            handleContractEffect: services.handleContractEffect,
            getC2BSub: services.getC2BSub,
            getSettings: services.getSettings,
            prepareSetBankDefault: services.prepareSetBankDefault,
            updateProduct: services.updateProduct
        )
    }
}

private struct FastPaymentsSettingsServices {
    
    let handleConsentListEffect: FastPaymentsSettingsEffectHandler.HandleConsentListEffect
    let handleContractEffect: FastPaymentsSettingsEffectHandler.HandleContractEffect
    let getC2BSub: FastPaymentsSettingsEffectHandler.GetC2BSub
    let getSettings: FastPaymentsSettingsEffectHandler.GetSettings
    let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefault
    let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProduct
}

// MARK: - Stubs

private extension FastPaymentsSettingsServices {
    
    static func stub() -> Self {
        
        let consentListHandler = ConsentListRxEffectHandler(
            changeConsentList: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.success)
                }
            }
        )
        
        let contractEffectHandler = ContractEffectHandler(
            createContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.success(.stub))
                }
            },
            updateContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.success(.stub))
                }
            }
        )
        
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
            handleConsentListEffect: consentListHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
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
