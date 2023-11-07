//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation

extension RootViewModelFactory {
    
    static func make(
        model: Model,
        logger: LoggerAgentProtocol
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        
        let (productProfileViewModelFactory, onRegister) = make(
            httpClient: httpClient,
            logger: logger,
            model: model
        )
        
        return make(
            model: model,
            productProfileViewModelFactory: productProfileViewModelFactory,
            onRegister: onRegister
        )
    }
}

// TODO: needs better naming
private extension RootViewModelFactory {
    
    typealias MakeProductProfileViewModelFactory = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    
    static func make(
        model: Model,
        productProfileViewModelFactory: @escaping MakeProductProfileViewModelFactory,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let mainViewModel = MainViewModel(
            model,
            productProfileViewModelFactory: productProfileViewModelFactory,
            onRegister: onRegister
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            productProfileViewModelFactory: productProfileViewModelFactory
        )
        
        let chatViewModel = ChatViewModel()
        
        let informerViewModel = InformerView.ViewModel(model)
        
        return .init(
            mainViewModel: mainViewModel,
            paymentsViewModel: paymentsViewModel,
            chatViewModel: chatViewModel,
            informerViewModel: informerViewModel,
            model,
            onRegister: onRegister
        )
    }
    
    static func make(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        model: Model
    ) -> (MakeProductProfileViewModelFactory, OnRegister) {
        
        let rsaKeyPairStore = makeLoggingStore(
            logger: logger
        )
        
        let onExit = rsaKeyPairStore.deleteCacheIgnoringResult
        
        let cvvPINServicesClient = Services.cvvPINServicesClient(
            httpClient: httpClient,
            logger: logger,
            rsaKeyPairStore: rsaKeyPairStore
        )
        
        let productProfileViewModelFactory = {
            
            ProductProfileViewModel(
                model,
                cvvPINServicesClient: cvvPINServicesClient,
                product: $0,
                rootView: $1,
                dismissAction: $2
            )
        }
        
        return (productProfileViewModelFactory, onExit)
    }
    
    static func makeLoggingStore(
        logger: LoggerAgentProtocol
    ) -> any Store<RSADomain.KeyPair> {
        
        let log = { logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        
        let store = KeyTagKeyChainStore<RSADomain.KeyPair>(keyTag: .rsa)
        let rsaKeyPairStore = LoggingStoreDecorator(
            decoratee: store,
            log: log
        )
        
        return rsaKeyPairStore
    }
}
