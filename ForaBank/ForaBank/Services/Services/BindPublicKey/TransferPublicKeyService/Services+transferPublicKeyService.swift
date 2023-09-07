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
    typealias SecKeyOTPEncrypter = OTPEncrypter<TransferPublicKeyDomain.OTP, SecKey>
    
    static func publicSecKeyTransferService(
        httpClient: HTTPClient
    ) -> PublicKeyTransferService {
        
        let otpEncrypter: SecKeyOTPEncrypter = .signing(
            mapOTP: { .init($0.value.utf8) },
            encryptWithTransportPublicRSAKey: ForaCrypto.Crypto.transportEncrypt
        )
        
        let keyCache = InMemoryKeyStore<SecKey>()
        
        let swaddler = SecKeySwaddler(
            generateRSA4096BitKeys: {
                try ForaCrypto.Crypto.createRandomSecKeys(
                    keyType: kSecAttrKeyTypeRSA,
                    keySizeInBits: 4096
                )
            },
            otpEncrypter: otpEncrypter,
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
            secKeySwaddler: swaddler,
            bindKeyService: bindKeyService
        )
    }
    
}

private extension Services.SecKeySwaddler {
    
    convenience init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        otpEncrypter: Services.SecKeyOTPEncrypter,
        saveKeys: @escaping SaveKeys,
        aesEncrypt128bitChunks: @escaping AESEncryptBits128Chunks
    ) {
        self.init(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            encryptOTPWithRSAKey: otpEncrypter.encrypt,
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: aesEncrypt128bitChunks
        )
    }
    
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

// MARK: - P384

extension Services {
    
    typealias TransferOTP = TransferPublicKeyDomain.OTP
    typealias ExchangeEventID = KeyExchangeDomain.KeyExchange.EventID
    typealias P384Swaddler = PublicRSAKeySwaddler<TransferOTP, P384KeyAgreementDomain.PrivateKey, P384KeyAgreementDomain.PublicKey>
    typealias PublicKeyTransferService = KeyTransferService<TransferOTP, ExchangeEventID>
    
    static func publicKeyTransferService(
        httpClient: HTTPClient
    ) -> PublicKeyTransferService {
        
        let otpEncrypter = otpEncrypter(
            withPublicKey: ForaCrypto.Crypto.transportKey
        )
        
        let keyCache = InMemoryKeyStore<P384KeyAgreementDomain.PrivateKey>()
        
        let swaddler = P384Swaddler(
            generateRSA4096BitKeys: ForaCrypto.Crypto.generateP384KeyPair,
            otpEncrypter: otpEncrypter,
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
    
    typealias TransferOTPEncrypter = OTPEncrypter<TransferOTP, P384KeyAgreementDomain.PrivateKey>
    
    #warning("remove if not used")
    static func otpEncrypter(
        withPublicKey publicKey: @escaping () throws -> SecKey
    ) -> TransferOTPEncrypter {
        
        #warning("try P384 direct encryption?")
        let signWithPadding: TransferOTPEncrypter.SignWithPadding = { otp, privateKey in
            
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
        
        return .init(
            signWithPadding: signWithPadding,
            encryptWithTransportPublicRSAKey: encryptWithTransportPublicRSAKey
        )
    }
}

// MARK: - Adapters

extension P384KeyAgreementDomain.PublicKey: RawRepresentational {}

private extension Services.P384Swaddler {
    
    convenience init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        otpEncrypter: Services.TransferOTPEncrypter,
        saveKeys: @escaping SaveKeys,
        aesEncrypt128bitChunks: @escaping AESEncryptBits128Chunks
    ) {
        self.init(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            encryptOTPWithRSAKey: otpEncrypter.encrypt,
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: aesEncrypt128bitChunks
        )
    }
    
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
