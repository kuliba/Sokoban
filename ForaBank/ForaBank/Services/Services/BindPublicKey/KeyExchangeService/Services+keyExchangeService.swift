//
//  Services+keyExchangeService.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import Foundation
import VortexCrypto
import GenericRemoteService

extension Services {
    
    static func keyExchangeService(
        httpClient: HTTPClient,
        cryptographer: KeyExchangeCryptographer
    ) -> KeyExchangeService {
        
        let keyPair = cryptographer.generateP384KeyPair()
        
        let secretRequestMaker = SecretRequestMaker(
            publicKeyData: {
                
                try cryptographer.publicKeyData(
                    keyPair.publicKey
                )
            },
            encrypt: cryptographer.transportEncrypt
        )
        
        typealias LoggingRequestCreator = LoggingDecoratedRequestCreator<FormSessionKeyDomain.Request>
        
        let loggingRequestCreator = LoggingRequestCreator(
            log: LoggerAgent.shared.log,
            decoratee: RequestFactory.makeSecretRequest
        )
        
        let formSessionKeyService = RemoteService(
            createRequest: loggingRequestCreator.createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: PublicServerSessionKeyMapper.map
        )
        
        let extractSharedSecret: KeyExchangeService.ExtractSharedSecret = { string, completion in
            
            completion(.init(catching: {
                
                try cryptographer.sharedSecret(string, keyPair.privateKey)
            }))
        }
        
        return .init(
            secretRequestMaker: secretRequestMaker,
            formSessionKeyService: formSessionKeyService,
            extractSharedSecret: extractSharedSecret
        )
    }
}

// MARK: - Cryptography Interface

struct KeyExchangeCryptographer {
    
    typealias PublicKey = P384KeyAgreementDomain.PublicKey
    typealias PrivateKey = P384KeyAgreementDomain.PrivateKey
    
    let generateP384KeyPair: () -> P384KeyAgreementDomain.KeyPair
    let publicKeyData: (PublicKey) throws -> Data
    let transportEncrypt: (Data) throws -> Data
    let sharedSecret: (String, PrivateKey) throws -> Data
}

// MARK: - Adapters

private extension KeyExchangeService {
    
    typealias FormSessionKeyService = RemoteServiceOf<FormSessionKeyDomain.Request, FormSessionKeyDomain.Response>
    
    convenience init(
        secretRequestMaker: SecretRequestMaker,
        formSessionKeyService: FormSessionKeyService,
        extractSharedSecret: @escaping ExtractSharedSecret
    ) {
        self.init(
            makeSecretRequest: secretRequestMaker.makeSecretRequest,
            formSessionKey: formSessionKeyService.get,
            extractSharedSecret: extractSharedSecret
        )
    }
}

extension RemoteService {
    
    typealias AnyErrorCompletion = (Result<Output, Error>) -> Void
    
    func get(
        _ request: Input,
        completion: @escaping AnyErrorCompletion
    ) {
        process(request) { result in
            
            completion(.init { try result.get() })
        }
    }
}
