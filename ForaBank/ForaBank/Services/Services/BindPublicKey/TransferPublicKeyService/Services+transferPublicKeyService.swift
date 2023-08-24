//
//  Services+publicKeyTransferService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import CryptoKit
import ForaCrypto
import Foundation
import TransferPublicKey
import GenericRemoteService

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
            aesEncrypt128bitChunks: {
                
#warning("FIX THIS")
                return $0
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
    
    static func otpEncrypter(
        withPublicKey publicKey: @escaping () throws -> SecKey
    ) -> TransferOTPEncrypter {
        
        let encryptWithPadding: TransferOTPEncrypter.EncryptWithPadding = { _,_ in
            
#warning("FIX THIS")
            return unimplemented("EncryptWithPadding")
        }
        
        let encryptWithTransportPublicRSAKey = { data in
            
            try Crypto.rsaPKCS1Encrypt(
                data: data,
                withPublicKey: publicKey()
            )
        }
        
        return .init(
            encryptWithPadding: encryptWithPadding,
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
    
#warning("Data is not used")
    func swaddle(
        otp: OTP,
        keyData: Data,
        completion: @escaping (Result<Data, any Error>) -> Void
    ) {
        completion(
            .init(catching: {
                
                try swaddleKey(with: otp)
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
    
    typealias Input = TransferPublicKey.PublicKeyWithEventID<Services.ExchangeEventID>
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
    
    typealias BindCompletion = Services.PublicKeyTransferService.BindKeyCompletion
    
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
