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
        
        let log = { LoggerAgent.shared.debug(category: $0, message: $1, file: $2, line: $3) }
        
        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            _transportKey: Crypto.transportKey,
            _processingKey: Crypto.processingKey,
            log: { log(.crypto, $0, $1, $2) }
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
                log: { log(.crypto, $0, $1, $2) }
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

// MARK: - Adapters

private extension LiveExtraLoggingCVVPINCrypto{
    
    init(
        _transportKey: @escaping () throws -> SecKey,
        _processingKey: @escaping () throws -> SecKey,
        log: @escaping Log
    ) {
        self.init(
            transportKey: {
                
                do {
                    return try LiveExtraLoggingCVVPINCrypto.TransportKey(
                        key: _transportKey()
                    )
                } catch {
                    log("Transport Key loading failure: \(error).", #file, #line)
                    throw error
                }
            },
            processingKey: {
                
                do {
                    return try LiveExtraLoggingCVVPINCrypto.ProcessingKey(
                        key: _processingKey()
                    )
                } catch {
                    log("Processing Key loading failure: \(error).", #file, #line)
                    throw error
                }
            },
            log: log
        )
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
