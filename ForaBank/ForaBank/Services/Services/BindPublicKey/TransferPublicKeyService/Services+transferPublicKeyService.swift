//
//  Services+publicKeyTransferService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import CryptoKit
import CryptoSwaddler
import ForaCrypto
import Foundation
import TransferPublicKey
import GenericRemoteService

// MARK: - SecKey

extension Services {
    
    typealias SecKeySwaddler = PublicRSAKeySwaddler<TransferOTP, SecKey, SecKey>
    
    static func publicSecKeyTransferService(
        httpClient: HTTPClient,
        transportKey: @escaping () throws -> SecKey = ForaCrypto.Crypto.transportKey
    ) -> PublicKeyTransferService {
        
        let generateRSA4096BitKeys = {
            
            try ForaCrypto.Crypto.createRandomSecKeys(
                keyType: kSecAttrKeyTypeRSA,
                keySizeInBits: 4096
            )
        }
        let signEncryptOTP: SecKeySwaddler.SignEncryptOTP = { otp, privateKey in
            
            let clientSecretOTP = try ForaCrypto.Crypto.sign(
                .init(otp.value.utf8),
                withPrivateKey: privateKey,
                algorithm: .rsaSignatureMessagePKCS1v15SHA256
            )
            
            let procClientSecretOTP = try ForaCrypto.Crypto.rsaEncrypt(
                data: clientSecretOTP,
                withPublicKey: transportKey(),
                algorithm: .rsaEncryptionRaw
            )
            
            return procClientSecretOTP
        }
        
        let keyCache = InMemoryKeyStore<SecKey>()
        let saveKeys: SecKeySwaddler.SaveKeys = { privateKey, publicKey in
            
            keyCache.saveKey(privateKey) { _ in
                #warning("FIX THIS")
            }
        }
        let aesEncrypt128bitChunks: SecKeySwaddler.AESEncrypt128bitChunks = { data, secret in
            
            let aes256CBC = try ForaCrypto.AES256CBC(key: secret.data)
            let result = try aes256CBC.encrypt(data)
            return result
        }
        
        let swaddler = SecKeySwaddler(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            signEncryptOTP: signEncryptOTP,
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: aesEncrypt128bitChunks
        )
        
        let bindKeyService = PublicKeyTransferService.BindKeyService(
            createRequest: RequestFactory.makeBindPublicKeyWithEventIDRequest,
            performRequest: httpClient.performRequest,
            mapResponse: BindPublicKeyWithEventIDMapper.map
        )
        
        return .init(
            secKeySwaddler: swaddler,
            bindKeyService: bindKeyService
        )
    }
}

private extension Services.PublicKeyTransferService {
    
    convenience init(
        secKeySwaddler: Services.SecKeySwaddler,
        bindKeyService: BindKeyService
    ) {
        self.init(
            swaddleKey: secKeySwaddler.swaddle,
            bindKey: bindKeyService.process
        )
    }
}

private extension Services.SecKeySwaddler {
    
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
            
            let key = try ForaCrypto.Crypto.createSecKeyWith(
                data: privateKey.derRepresentation
            )
            
            return try ForaCrypto.Crypto.sign(
                .init(otp.value.utf8),
                withPrivateKey: key
            )
        }
        
        let encryptWithTransportPublicRSAKey = { data in
            
            try ForaCrypto.Crypto.rsaEncrypt(
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

extension P384KeyAgreementDomain.PublicKey: RawRepresentational {}

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

private extension Services.PublicKeyTransferService {
    
    typealias Input = BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.PublicKeyWithEventID
    typealias BindKeyService = RemoteService<Input, Void>
    
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
