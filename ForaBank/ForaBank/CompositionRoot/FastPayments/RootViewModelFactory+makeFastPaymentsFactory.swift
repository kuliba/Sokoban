//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import FastPaymentsSettings
import Foundation
import UserAccountNavigationComponent

extension RootViewModelFactory {
    
    static func makeNewFastPaymentsViewModel(
        httpClient: HTTPClient,
        model: Model,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> FastPaymentsSettingsViewModel {
        
        let getProducts: () -> [Product] = {
            
#warning("replace with mapping and filtering products from model")
            return .preview
        }
        
        let bankDefaultReducer = BankDefaultReducer()
        let consentListReducer = ConsentListRxReducer()
        let contractReducer = ContractReducer(getProducts: getProducts)
        let productsReducer = ProductsReducer(getProducts: getProducts)
        
        let reducer = FastPaymentsSettingsReducer(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            consentListReduce: consentListReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
        
#warning("replace stubs with services")
        let effectHandler = FastPaymentsSettingsEffectHandler.stub(
            consentListHandler: .stub,
            contractEffectHandler: .stub
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
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
}

#warning("replace stubs with real")
// MARK: - Stubs

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

private extension ConsentListRxEffectHandler {
    
    static let stub: ConsentListRxEffectHandler = .init(
        changeConsentList: { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success)
            }
        }
    )
}

private extension ContractEffectHandler {
    
    static let stub: ContractEffectHandler = .init(
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
}

private extension FastPaymentsSettingsEffectHandler {
    
    static func stub(
        consentListHandler: ConsentListRxEffectHandler,
        contractEffectHandler: ContractEffectHandler
    ) -> FastPaymentsSettingsEffectHandler {
        
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
