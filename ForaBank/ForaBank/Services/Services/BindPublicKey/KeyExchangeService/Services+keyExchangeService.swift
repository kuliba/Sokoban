//
//  Services+keyExchangeService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CryptoKit
import CvvPin
import ForaCrypto
import Foundation
import GenericRemoteService

extension PublicTransportKeyDomain {
    
    static func encrypt(_ data: Data) throws -> Data {
        
        try ForaCrypto.Crypto.transportEncrypt(data, padding: .PKCS1)
    }
    
    static func decrypt(_ data: Data) throws -> Data {
        
        try ForaCrypto.Crypto.rsaPKCS1Decrypt(data: data, withPrivateKey: fromCert())
    }
}

extension KeyExchangeService: KeyExchangeServiceProtocol {}

extension Services {
    
    static func keyExchangeService(
        httpClient: HTTPClient
    ) -> KeyExchangeService {
        
        let keyPair = ForaCrypto.Crypto.generateP384KeyPair()
        
        let publicKeyData = keyPair.publicKey.derRepresentation
        
        let secretRequestMaker = SecretRequestMaker(
            publicKeyData: { publicKeyData },
            encrypt: PublicTransportKeyDomain.encrypt
        )
        
        let formSessionKeyService = RemoteService(
            createRequest: RequestFactory.makeSecretRequest,
            performRequest: httpClient.performRequest,
            mapResponse: PublicServerSessionKeyMapper.map
        )
        
        let extractSharedSecret: KeyExchangeService.ExtractSharedSecret = { string, completion in
            
            completion(.init(catching: {
                #warning("extract as method to ForaCrypto.Crypto")
                let serverPublicKey = try ForaCrypto.Crypto.transportDecryptP384PublicKey(from: string)
                let sharedSecret = try ForaCrypto.Crypto.sharedSecret(
                    privateKey: keyPair.privateKey,
                    publicKey: serverPublicKey
                )
                
                return sharedSecret
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

extension RemoteService: CryptoAPIClient {
    
    public func get(
        _ request: Input,
        completion: @escaping Completion
    ) {
        process(request, completion: completion)
    }
}
