//
//  Services+cryptoLoggingCVVPINServicesClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import Foundation

extension Services {
    
    static func cryptoLoggingCVVPINServicesClient(
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
