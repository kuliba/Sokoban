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
        
        let sessionCodeService = getProcessingSessionCode(
            httpClient: httpClient
        )
        
        let keyExchangeService = keyExchangeService(
            httpClient: httpClient
        )
        
        let transferPublicKeyService = publicKeyTransferService(
            httpClient: httpClient
        )
        
        return .init(
            sessionCodeService: sessionCodeService,
            keyExchangeService: keyExchangeService,
            transferKeyService: transferPublicKeyService
        )
    }
    
    //    func transfer(
    //        otp: BindPublicKeyDomain.OTP,
    //        andSharedSecret data: Data,
    //        completion: @escaping Completion
    //    ) -> Void {
//    static func bind(
//        generateRSA4096BitKeys: @escaping () throws -> (SecKey, SecKey),
//        encryptOTPWithRSAKey: @escaping (OTP, SecKey) throws -> Data
//    ) -> CvvPinService.BindPublicKey {
//
//        return { otp, sharedSecret, completion in
//
//            //let (encryptedOTP, privateRSAKey, publicRSAKey)
//            // wrap everything in KeyCachingAdapter (saveKeys)
//            let (encryptedOTP, privateKey, publicKey) = try
//            // or RetryAdapter
//            retry {
//
//                let (privateKey, publicKey) = try generateRSA4096BitKeys()
//                let encryptedOTP = try encryptOTPWithRSAKey(otp, privateKey)
//
//                return (encryptedOTP, privateKey, publicKey)
//            }
//
//            // ...
//            fatalError()
//        }
//    }
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

// MARK: - Adapters

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
