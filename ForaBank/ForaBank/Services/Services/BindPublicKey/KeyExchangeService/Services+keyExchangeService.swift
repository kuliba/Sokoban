//
//  Services+keyExchangeService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import Foundation
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

// MARK: - Adapters

private extension KeyExchangeService {
    
    typealias FormSessionKeyService = RemoteService<FormSessionKeyDomain.Request, FormSessionKeyDomain.Response>
    
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
    
    public func get(
        _ request: Input,
        completion: @escaping Completion
    ) {
        process(request, completion: completion)
    }
}
