//
//  CVVPINServicesFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.11.2023.
//

import ForaCrypto
import Foundation

enum CVVPINServicesFactory {}

extension CVVPINServicesFactory {
    
    static func makeClient(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol
    ) -> CVVPINServicesClient {
        
        let log = logger.log(level:category:message:file:line:)
        
        typealias Crypto = ForaCrypto.Crypto

        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            _transportKey: Crypto.transportKey,
            _processingKey: Crypto.processingKey,
            log: { log(.error, .crypto, $0, $1, $2) }
        )
        
#warning("fix lifespans before release")
       let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        
        let (cvvPINServicesClient, _) = Services.cvvPINServicesClient(
            httpClient: httpClient,
            cvvPINCrypto: LoggingCVVPINCryptoDecorator(
                decoratee: cvvPINCrypto,
                log: { log($0, .crypto, $1, $2, $3) }
            ),
            cvvPINJSONMaker: LoggingCVVPINJSONMakerDecorator(
                decoratee: cvvPINJSONMaker,
                log: { log($0, .crypto, $1, $2, $3) }
            ),
            rsaKeyPairLifespan: .rsaKeyPairLifespan,
            ephemeralLifespan: .ephemeralLifespan,
            log: log
        )

        return cvvPINServicesClient
    }
}

extension LiveExtraLoggingCVVPINCrypto: CVVPINCrypto {}
extension LiveCVVPINJSONMaker: CVVPINJSONMaker {}

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
