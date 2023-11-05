//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import ForaCrypto
import Foundation

enum RootViewModelFactory {
    
    typealias Crypto = ForaCrypto.Crypto
    
    static func make(
        with model: Model
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        let logger = LoggerAgent.shared

        let rsaKeyPairStore = CryptoStorageFactory.makeLoggingStore(
            logger: logger
        )
        
        let onExit = rsaKeyPairStore.deleteCacheIgnoringResult
        
        let cvvPINServicesClient = CVVPINServicesFactory.makeClient(
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
}
