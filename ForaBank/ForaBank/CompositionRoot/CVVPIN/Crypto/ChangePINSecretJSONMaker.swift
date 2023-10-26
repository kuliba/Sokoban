//
//  ChangePINSecretJSONMaker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.10.2023.
//

import CryptoKit
import CVVPINServices
import CVVPIN_Services
import ForaCrypto
import Foundation

typealias ChangePINSecretJSONMaker = SecretPINRequestMaker<CardID, CVVPIN_Services.ChangePINService.OTPEventID, OTP, PIN, CVVPIN_Services.ChangePINService.SessionID, SessionKey>


extension CVVPIN_Services.ChangePINService.SessionID: RawRepresentable {
    
    public var rawValue: String { sessionIDValue }
    
    public init(rawValue: String) {
        
        self.init(sessionIDValue: rawValue)
    }
}

extension CVVPIN_Services.ChangePINService.OTPEventID: RawRepresentable {
    
    public var rawValue: String { eventIDValue }
    
    public init(rawValue: String) {
        
        self.init(eventIDValue: rawValue)
    }
}

extension ChangePINSecretJSONMaker
where SymmetricKey == SessionKey {
    
    private static var log: (String) -> Void  {
        
        return {
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: $0)
        }
    }
    
    static var loggingLive: Self {
        return .init(
            crypto: .init(
                aesEncrypt: { data, sessionKey in
                    
                    do {
                        let encrypted = try BindPublicKeyCrypto.aesEncrypt(data: data .data, sessionKey: sessionKey)
                        log("AES Encrypted data (\(data.count))")
                        
                        return encrypted
                    } catch {
                        log("AES Encryption Failure: \(error).")
                        throw error
                    }
                },
                encryptWithProcessingPublicRSAKey: { data in
                    do {
                        let encrypted = try ForaCrypto.Crypto.processingEncrypt(data)
                        log("Successful Encryption with Processing Public RSA Key (\(data.count))")
                        return encrypted
                    } catch {
                        log("Encryption with Processing Public RSA Key Failure: \(error).")
                        throw error
                    }
                },
                sha256Hash: { string in
                    
                    SHA256
                        .hash(data: Data(string.utf8))
                        .withUnsafeBytes { Data($0) }
                }
            )
        )
    }
}

private extension ForaCrypto.Crypto {
    
    static func processingEncrypt(
        _ data: Data
    ) throws -> Data {
        
        try ForaCrypto.Crypto.processingEncrypt(data, padding: .PKCS1)
    }
}
