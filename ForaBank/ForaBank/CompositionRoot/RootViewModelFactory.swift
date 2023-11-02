//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import ForaCrypto
import Foundation

enum RootViewModelFactory {
    
    static func make(
        with model: Model
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        
        let log = { LoggerAgent.shared.debug(category: $0, message: $1, file: $2, line: $3) }
        
        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            log: { log(.crypto, $0, #file, #line) }
        )
        
        let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        
#warning("fix lifespans before release")
        let (cvvPINServicesClient, onExit) = Services.cvvPINServicesClient(
            httpClient: httpClient,
            cvvPINCrypto: LoggingCVVPINCryptoDecorator(
                decoratee: cvvPINCrypto,
                log: { log(.crypto, $0, $1, $2) }
            ),
            cvvPINJSONMaker: LoggingCVVPINJSONMakerDecorator(
                decoratee: cvvPINJSONMaker,
                log: { log(.crypto, $0, #file, #line) }
            ),
            rsaKeyPairLifespan: .rsaKeyPairLifespan,
            ephemeralLifespan: .ephemeralLifespan,
            log: log
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

extension LiveExtraLoggingCVVPINCrypto: CVVPINCrypto {}
extension LiveCVVPINJSONMaker: CVVPINJSONMaker {}

extension LoggerAgentProtocol {
    
    func debug(category: LoggerAgentCategory, message: String, file: StaticString = #file, line: UInt = #line) {
        
        log(level: .debug, category: category, message: message, file: file, line: line)
    }
}

// MARK: - Lifespans

private extension TimeInterval {
    
    static var rsaKeyPairLifespan: Self {
        
#if RELEASE
        15_778_463
#else
        600
#endif
    }
    
    static var ephemeralLifespan: Self {
        
#if RELEASE
        15
#else
        30
#endif
    }
}
