//
//  Services+makeKeyTransferService.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CvvPin
import Foundation
import TransferPublicKey

extension Services {
    
    typealias SecKeySwaddler = PublicRSAKeySwaddler<Services.TransferOTP, SecKey, SecKey>

    static func makeKeyTransferService(
        httpClient: HTTPClient,
        cryptographer: SecKeySwaddleCryptographer
    ) -> KeyTransferService<TransferPublicKeyDomain.OTP, KeyExchangeDomain.KeyExchange.EventID> {
        
        let secKeySwaddler = SecKeySwaddler(
            generateRSA4096BitKeys: cryptographer.generateRSA4096BitKeys,
            signEncryptOTP: cryptographer.signEncryptOTP,
            saveKeys: cryptographer.saveKeys,
            x509Representation: cryptographer.x509Representation,
            aesEncrypt128bitChunks: cryptographer.aesEncrypt128bitChunks
        )
        
        let bindKeyService = bindKeyService(
            httpClient: httpClient
        )
        
        return .init(
            swaddleKey: secKeySwaddler.swaddle,
            bindKey: bindKeyService.process
        )
    }
}

// MARK: - Cryptography Interface

struct SecKeySwaddleCryptographer {
    
    typealias SecKeySwaddler = Services.SecKeySwaddler
    
    let generateRSA4096BitKeys: () throws -> (privateKey: SecKey, publicKey: SecKey)
    let signEncryptOTP: SecKeySwaddler.SignEncryptOTP
    let saveKeys: SecKeySwaddler.SaveKeys
    let x509Representation: SecKeySwaddler.X509Representation
    let aesEncrypt128bitChunks: SecKeySwaddler.AESEncrypt128bitChunks
}

// MARK: - Adapters

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

