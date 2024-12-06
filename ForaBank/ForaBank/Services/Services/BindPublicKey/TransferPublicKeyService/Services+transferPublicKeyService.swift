//
//  Services+publicKeyTransferService.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import CryptoKit
import CryptoSwaddler
import ForaCrypto
import Foundation
import GenericRemoteService
import TransferPublicKey

// MARK: - P384

extension Services {
    
    typealias TransferOTP = TransferPublicKeyDomain.OTP
    typealias ExchangeEventID = KeyExchangeDomain.KeyExchange.EventID
    typealias P384Swaddler = PublicRSAKeySwaddler<TransferOTP, P384KeyAgreementDomain.PrivateKey, P384KeyAgreementDomain.PublicKey>
    typealias PublicKeyTransferService = KeyTransferService<TransferOTP, ExchangeEventID>
    
    static func publicKeyTransferService(
        httpClient: HTTPClient
    ) -> PublicKeyTransferService {
        
        let signEncryptOTP = signEncryptOTP(
            withPublicKey: ForaCrypto.Crypto.transportKey
        )
        
        let keyCache = InMemoryKeyStore<P384KeyAgreementDomain.PrivateKey>()
        
        let swaddler = P384Swaddler(
            generateRSA4096BitKeys: ForaCrypto.Crypto.generateP384KeyPair,
            signEncryptOTP: signEncryptOTP,
            saveKeys: { privateKey, publicKey in
                
                keyCache.saveKey(privateKey) { _ in
#warning("FIX THIS")
                }
            },
            x509Representation: { _ in unimplemented() },
            aesEncrypt128bitChunks: { data, secret in
                
                //    let aesGCMEncryptionAgent = AESGCMEncryptionAgent(data: secret.data)
                //    return try aesGCMEncryptionAgent.encrypt(data)
                
                let aes256CBC = try ForaCrypto.AES256CBC(key: secret.data)
                let result = try aes256CBC.encrypt(data)
                return result
            }
        )
        
        let bindKeyService = PublicKeyTransferService.BindKeyService(
            createRequest: RequestFactory.makeBindPublicKeyWithEventIDRequest,
            performRequest: httpClient.performRequest,
            mapResponse: BindPublicKeyWithEventIDMapper.map
        )
        
        return .init(
            swaddler: swaddler,
            bindKeyService: bindKeyService
        )
    }
    
    typealias TransferSignEncryptOTP = (TransferOTP, P384KeyAgreementDomain.PrivateKey) throws -> Data
    
#warning("remove if not used")
    static func signEncryptOTP(
        withPublicKey publicKey: @escaping () throws -> SecKey
    ) -> TransferSignEncryptOTP {
        
#warning("try P384 direct encryption?")
        let signWithPadding: TransferSignEncryptOTP = { otp, privateKey in
            
            let key = try ForaCrypto.Crypto.createSecKey(
                from: privateKey.derRepresentation,
                keyType: .rsa,
                keyClass: .privateKey
            )
            
            return try ForaCrypto.Crypto.sign(
                .init(otp.value.utf8),
                withPrivateKey: key,
                algorithm: .rsaSignatureDigestPKCS1v15SHA256
            )
        }
        
        let encryptWithTransportPublicRSAKey = { data in
            
            try ForaCrypto.Crypto.encrypt(
                data: data,
                withPublicKey: publicKey(),
                algorithm: .rsaEncryptionRaw
            )
        }
        
        return { otp, privateKey in
            
            let signed = try signWithPadding(otp, privateKey)
            
            return try encryptWithTransportPublicRSAKey(signed)
        }
    }
}

// MARK: - Adapters

private extension Services.P384Swaddler {
    
    func swaddle(
        otp: OTP,
        sharedSecret: SwaddleKeyDomain<OTP>.SharedSecret,
        completion: @escaping (Result<Data, any Error>) -> Void
    ) {
        completion(
            .init(catching: {
                
                try swaddleKey(with: otp, and: sharedSecret)
            })
        )
    }
}

private extension BindPublicKeyWithEventIDMapper {
    
    static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) throws {
        
        guard let error = map(data, response) else {
            return
        }
        
        throw error
    }
}

extension Services.PublicKeyTransferService {
    
    typealias Input = BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.PublicKeyWithEventID
    typealias BindKeyService = RemoteServiceOf<Input, Void>
    
    convenience init(
        swaddler: Services.P384Swaddler,
        bindKeyService: BindKeyService
    ) {
        self.init(
            swaddleKey: swaddler.swaddle,
            bindKey: bindKeyService.process
        )
    }
}

private extension Services.PublicKeyTransferService.BindKeyService {
    
    typealias BindCompletion = BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.Completion
    
    func process(
        input: Input,
        completion: @escaping BindCompletion
    ) {
        self.process(input) { result in
            
            switch result {
            case let .failure(error as ErrorWithRetryAttempts):
                completion(.failure(error))
                
            case let .failure(error):
                completion(.failure(.init(error: error, retryAttempts: 0)))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}
