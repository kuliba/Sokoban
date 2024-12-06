//
//  Services+cvvPINServicesClient.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.11.2023.
//

import ForaCrypto
import Foundation

// MARK: - Lifespans

private extension TimeInterval {
    
    static var cvvPINActivationLifespan: Self {
        
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

// MARK: - CVVPINServicesClient

extension Services {
    
    typealias RSAKeyPairStore = Store<RSADomain.KeyPair>
    
    static func cvvPINServicesClient(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        rsaKeyPairStore: any RSAKeyPairStore
    ) -> CVVPINServicesClient {
        
        let cryptoLog = { logger.log(level: $0, category: .crypto, message: $1, file: $2, line: $3) }
        
        let crypto = LiveExtraLoggingCVVPINCrypto(
            _transportKey: ForaCrypto.Crypto.transportKey,
            _processingKey: ForaCrypto.Crypto.processingKey,
            errorLog: { cryptoLog(.error, $0, $1, $2) }
        )
        let cvvPINCrypto = LoggingCVVPINCryptoDecorator(
            decoratee: crypto,
            log: cryptoLog
        )
        
        let jsonMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        let cvvPINJSONMaker = LoggingCVVPINJSONMakerDecorator(
            decoratee: jsonMaker,
            log: cryptoLog
        )
        
        return Services.composedCVVPINService(
            httpClient: httpClient,
            logger: logger,
            rsaKeyPairStore: rsaKeyPairStore,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker,
            cvvPINActivationLifespan: .cvvPINActivationLifespan,
            ephemeralLifespan: .ephemeralLifespan
        )
    }
}

extension LiveExtraLoggingCVVPINCrypto: CVVPINCrypto {}
extension LiveCVVPINJSONMaker: CVVPINJSONMaker {}

// MARK: - Adapters

private extension LiveExtraLoggingCVVPINCrypto{
    
    init(
        _transportKey: @escaping () throws -> SecKey,
        _processingKey: @escaping () throws -> SecKey,
        errorLog: @escaping Log
    ) {
        self.init(
            transportKey: {
                
                do {
                    return try LiveExtraLoggingCVVPINCrypto.TransportKey(
                        key: _transportKey()
                    )
                } catch {
                    errorLog("Transport Key loading failure: \(error).", #file, #line)
                    throw error
                }
            },
            processingKey: {
                
                do {
                    return try LiveExtraLoggingCVVPINCrypto.ProcessingKey(
                        key: _processingKey()
                    )
                } catch {
                    errorLog("Processing Key loading failure: \(error).", #file, #line)
                    throw error
                }
            },
            log: errorLog
        )
    }
}
