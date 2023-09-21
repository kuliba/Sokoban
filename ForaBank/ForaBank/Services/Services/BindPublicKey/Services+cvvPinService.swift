//
//  Services+cvvPinService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2023.
//

import CvvPin
import CryptoKit
import ForaCrypto
import Foundation
import GenericRemoteService
import GetProcessingSessionCodeService
import TransferPublicKey

extension Services {
    
    // TODO: Move to the Composition Root
    static func cvvPinService(
        httpClient: HTTPClient
    ) -> CvvPinService {
        
        .init(
            sessionCodeService: getProcessingSessionCode(
                httpClient: httpClient
            ),
            keyExchangeService: keyExchangeService(
                httpClient: httpClient,
                cryptographer: .live
            ),
            transferKeyService: .init(
                secKeySwaddler: .init(
                    cryptographer: .live
                ),
                bindKeyService: bindKeyService(
                    httpClient: httpClient
                )
            )
        )
    }
}

// MARK: - Cryptography

struct KeyExchangeCryptographer {
    
    typealias PublicKey = P384KeyAgreementDomain.PublicKey
    typealias PrivateKey = P384KeyAgreementDomain.PrivateKey
    
    let generateP384KeyPair: () -> P384KeyAgreementDomain.KeyPair
    let publicKeyData: (PublicKey) throws -> Data
    let transportEncrypt: (Data) throws -> Data
    let sharedSecret: (String, PrivateKey) throws -> Data
}

extension KeyExchangeCryptographer {
    
    static let live: Self = .init(
        generateP384KeyPair: ForaCrypto.Crypto.generateP384KeyPair,
        publicKeyData: { $0.derRepresentation },
        transportEncrypt: { data in
            
            try ForaCrypto.Crypto.transportEncrypt(data, padding: .PKCS1)
        },
        sharedSecret: { string, privateKey in
            
            let serverPublicKey = try ForaCrypto.Crypto.transportDecryptP384PublicKey(from: string)
            let sharedSecret = try ForaCrypto.Crypto.sharedSecret(
                privateKey: privateKey,
                publicKey: serverPublicKey
            )
            
            return sharedSecret
        }
    )
}

struct SecKeySwaddleCryptographer {
    
    typealias SecKeySwaddler = PublicRSAKeySwaddler<Services.TransferOTP, SecKey, SecKey>
    
    let generateRSA4096BitKeys: () throws -> (privateKey: SecKey, publicKey: SecKey)
    let signEncryptOTP: SecKeySwaddler.SignEncryptOTP
    let saveKeys: SecKeySwaddler.SaveKeys
    let aesEncrypt128bitChunks: SecKeySwaddler.AESEncrypt128bitChunks
}

extension SecKeySwaddleCryptographer {
    
    static let live: Self = .init(
        generateRSA4096BitKeys: {
            
            try ForaCrypto.Crypto.createRandomSecKeys(
                keyType: kSecAttrKeyTypeRSA,
                keySizeInBits: 4096
            )
        },
        signEncryptOTP: { otp, privateKey in
            
            let clientSecretOTP = try ForaCrypto.Crypto.sign(
                .init(otp.value.utf8),
                withPrivateKey: privateKey,
                algorithm: .rsaSignatureDigestPKCS1v15SHA256
            )
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create \"clientSecretOTP\" (signed OTP): \(clientSecretOTP)")
            
            let transportKeyEncrypt: (Data) throws -> Data = {
        
        let encrypted = try ForaCrypto.Crypto.rsaEncrypt(
            data: $0,
            withPublicKey: ForaCrypto.Crypto.transportKey(),
            algorithm: .rsaEncryptionRaw
        )
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Encrypted with transport public key: \(encrypted)")
        
        return encrypted
    }
            
            let procClientSecretOTP = try transportKeyEncrypt(
                clientSecretOTP
            )
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create \"procClientSecretOTP\" (encrypted \"clientSecretOTP\"): \(procClientSecretOTP)")
            
            return procClientSecretOTP
        },
        saveKeys:  { privateKey, publicKey in
            
            let keyCache = InMemoryKeyStore<SecKey>()
            let saveKeys: SecKeySwaddler.SaveKeys = { privateKey, publicKey in
        
        keyCache.saveKey(privateKey) { _ in
            #warning("FIX THIS")
    }
    }
        },
        aesEncrypt128bitChunks: { data, secret in
            
            let aes256CBC = try ForaCrypto.AES256CBC(key: secret.data)
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create AES256CBC with key \"\(secret.data)\"")
            
            let result = try aes256CBC.encrypt(data)
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "AES encrypt data \"\(data)\"")
            
            return result
        }
    )
}

// MARK: - Adapters

extension Services {
    
    typealias SecKeySwaddler = PublicRSAKeySwaddler<TransferOTP, SecKey, SecKey>
}

private extension CvvPinService {
    
    typealias EventID = KeyExchangeDomain.KeyExchange.EventID
    
    convenience init(
        sessionCodeService: GetProcessingSessionCodeService,
        keyExchangeService: KeyExchangeService,
        transferKeyService: KeyTransferService<OTP, EventID>
    ) {
        self.init(
            getProcessingSessionCode: sessionCodeService.process,
            exchangeKey: keyExchangeService.exchangeKey,
            transferPublicKey: transferKeyService.transfer
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

private extension PublicRSAKeySwaddler
where OTP == Services.TransferOTP,
      PrivateKey == SecKey,
      PublicKey == SecKey{
    
    convenience init(
        cryptographer: SecKeySwaddleCryptographer
    ) {
        self.init(
            generateRSA4096BitKeys: cryptographer.generateRSA4096BitKeys,
            signEncryptOTP: cryptographer.signEncryptOTP,
            saveKeys: cryptographer.saveKeys,
            aesEncrypt128bitChunks: cryptographer.aesEncrypt128bitChunks
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

private extension GetProcessingSessionCodeService {
    
    typealias GetResult = GetProcessingSessionCodeDomain.Result
    typealias GetCompletion = GetProcessingSessionCodeDomain.Completion
    
    func process(completion: @escaping GetCompletion) {
        
        process { result in
            
            let result: GetResult = result
                .map { .init(value: $0.code) }
                .mapError { $0 }
            
            completion(result)
        }
    }
}

private extension KeyTransferService
where OTP == TransferPublicKeyDomain.OTP,
      EventID == KeyExchangeDomain.KeyExchange.EventID {
    
    func transfer(
        otp: TransferPublicKeyDomain.OTP,
        eventID: TransferPublicKeyDomain.EventID,
        sharedSecret: TransferPublicKeyDomain.SharedSecret,
        completion: @escaping TransferPublicKeyDomain.Completion
    ) {
        transfer(
            otp: otp,
            eventID: eventID.eventID,
            sharedSecret: sharedSecret.secret
        ) { result in
            
            completion(result.mapError { $0 })
        }
    }
}

private extension TransferPublicKeyDomain.EventID {
    
    var eventID: KeyExchangeDomain.KeyExchange.EventID {
        
        .init(value: value)
    }
}

private extension TransferPublicKeyDomain.SharedSecret {
    
    var secret: SwaddleKeyDomain<TransferPublicKeyDomain.OTP>.SharedSecret {
        
        .init(data)
    }
}
