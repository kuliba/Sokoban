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
                cryptographer: .init()
            ),
            transferKeyService: .init(
                secKeySwaddler: secKeySwaddler(),
                bindKeyService: bindKeyService(
                    httpClient: httpClient
                )
            )
        )
    }
}

struct KeyExchangeCryptographer {
    
    typealias PublicKey = P384KeyAgreementDomain.PublicKey
    typealias PrivateKey = P384KeyAgreementDomain.PrivateKey
    
    let generateP384KeyPair: () -> P384KeyAgreementDomain.KeyPair = ForaCrypto.Crypto.generateP384KeyPair
    let publicKeyData: (PublicKey) throws -> Data = { $0.derRepresentation }
    let transportEncrypt: (Data) throws -> Data = { data in
        
        try ForaCrypto.Crypto.transportEncrypt(data, padding: .PKCS1)
    }
    let sharedSecret = { string, privateKey in
        
        let serverPublicKey = try ForaCrypto.Crypto.transportDecryptP384PublicKey(from: string)
        let sharedSecret = try ForaCrypto.Crypto.sharedSecret(
            privateKey: privateKey,
            publicKey: serverPublicKey
        )
        
        return sharedSecret
    }
}

// MARK: - Adapters

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
