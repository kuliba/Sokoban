//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import ForaCrypto
import Foundation

enum RootViewModelFactory {}

extension RootViewModelFactory {
    
    static func make(
        model: Model,
        logger: LoggerAgentProtocol
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        
        let (productProfileViewModelFactory, onExit) = make(
            httpClient: httpClient,
            logger: logger,
            model: model
        )
        
        return make(
            model: model,
            productProfileViewModelFactory: productProfileViewModelFactory,
            onExit: onExit
        )
    }
}

// TODO: needs better naming
private extension RootViewModelFactory {
    
    typealias MakeProductProfileViewModelFactory = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnExit = () -> Void
    
    static func make(
        model: Model,
        productProfileViewModelFactory: @escaping MakeProductProfileViewModelFactory,
        onExit: @escaping OnExit
    ) -> RootViewModel {
        
        let mainViewModel = MainViewModel(
            model,
            productProfileViewModelFactory: productProfileViewModelFactory,
            onExit: onExit
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            productProfileViewModelFactory: productProfileViewModelFactory,
            onExit: onExit
        )
        
        let chatViewModel = ChatViewModel()
        
        let informerViewModel = InformerView.ViewModel(model)
        
        return .init(
            mainViewModel: mainViewModel,
            paymentsViewModel: paymentsViewModel,
            chatViewModel: chatViewModel,
            informerViewModel: informerViewModel,
            model,
            onExit: onExit
        )
    }
    
    static func make(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        model: Model
    ) -> (MakeProductProfileViewModelFactory, OnExit) {
        
        let rsaKeyPairStore = makeLoggingStore(
            logger: logger
        )
        
        let onExit = rsaKeyPairStore.deleteCacheIgnoringResult
        
        let cvvPINServicesClient = CVVPINServicesFactory.makeCVVPINServicesClient(
            httpClient: httpClient,
            logger: logger,
            rsaKeyPairStore: rsaKeyPairStore
        )
        
        let productProfileViewModelFactory = {
            
            ProductProfileViewModel(
                model,
                cvvPINServicesClient: cvvPINServicesClient,
                onExit: onExit,
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
