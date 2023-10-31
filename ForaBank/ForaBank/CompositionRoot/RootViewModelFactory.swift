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
        
        let cvvPINServicesClient = Services.loggingCVVPINServicesClient(
            httpClient: httpClient,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker,
            log: log
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
        
        let mainViewModel = MainViewModel(
            model,
            productProfileViewModelFactory: productProfileViewModelFactory
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
            model
        )
    }
}

extension LiveExtraLoggingCVVPINCrypto: CVVPINCrypto {}
extension LiveCVVPINJSONMaker: CVVPINJSONMaker {}

private extension Services {
    
    static func loggingCVVPINServicesClient(
        httpClient: HTTPClient,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init,
        log: @escaping Log
    ) -> CVVPINServicesClient {
        
        cvvPINServicesClient(
            httpClient: httpClient,
            cvvPINCrypto: LoggingCVVPINCryptoDecorator(
                decoratee: cvvPINCrypto,
                log: { log(.crypto, $0, #file, #line) }
            ),
            cvvPINJSONMaker: LoggingCVVPINJSONMakerDecorator(
                decoratee: cvvPINJSONMaker,
                log: { log(.crypto, $0, #file, #line) }
            ),
            currentDate: currentDate,
            log: log
        )
    }
}

extension LoggerAgentProtocol {
    
    func debug(category: LoggerAgentCategory, message: String, file: StaticString = #file, line: UInt = #line) {
        
        log(level: .debug, category: category, message: message, file: file, line: line)
    }
}
