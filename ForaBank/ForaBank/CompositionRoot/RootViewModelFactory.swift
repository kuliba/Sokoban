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
        
        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            agent: LoggerAgent.shared
        )
        let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        
        let cvvPINServicesClient = Services.loggingCVVPINServicesClient(
            httpClient: httpClient,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker,
            loggerAgent: LoggerAgent.shared
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

private extension LiveExtraLoggingCVVPINCrypto {
    
    init(agent: LoggerAgentProtocol) {
        
        self.init(
            log: { agent.log(level: .debug, category: .crypto, message: $0, file: #file, line: #line) }
        )
    }
}

private extension Services {
    
    static func loggingCVVPINServicesClient(
        httpClient: HTTPClient,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        loggerAgent: LoggerAgentProtocol,
        currentDate: @escaping () -> Date = Date.init
    ) -> CVVPINServicesClient {
        
        cvvPINServicesClient(
            httpClient: httpClient,
            cvvPINCrypto: LoggingCVVPINCryptoDecorator(
                decoratee: cvvPINCrypto,
                agent: loggerAgent
            ),
            cvvPINJSONMaker: LoggingCVVPINJSONMakerDecorator(
                decoratee: cvvPINJSONMaker,
                agent: loggerAgent
            ),
            currentDate: currentDate
        )
    }
}

private extension LoggingCVVPINJSONMakerDecorator {
    
    convenience init(
        decoratee: CVVPINJSONMaker,
        agent: LoggerAgentProtocol
    ) {
        self.init(
            decoratee: decoratee,
            log: { agent.log(level: .debug, category: .crypto, message: $0, file: #file, line: #line) }
        )
    }
}

private extension LoggingCVVPINCryptoDecorator {
    
    convenience init(
        decoratee: CVVPINCrypto,
        agent: LoggerAgentProtocol
    ) {
        self.init(
            decoratee: decoratee,
            log: { agent.log(level: .debug, category: .crypto, message: $0, file: #file, line: #line) }
        )
    }
}
