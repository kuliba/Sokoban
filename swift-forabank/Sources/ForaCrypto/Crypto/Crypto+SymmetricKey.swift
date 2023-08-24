//
//  Crypto+SymmetricKey.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import CryptoKit
import Foundation

public extension Crypto {
    
    /// Creates `SymmetricKey` using private and public keys.
    static func hkdfDeriveSymmetricKey<H>(
        privateKey: P384.KeyAgreement.PrivateKey,
        publicKey: P384.KeyAgreement.PublicKey,
        using hashFunction: H.Type = SHA384.self,
        protocolSalt: any DataProtocol = "CryptoKit Key Agreement".data(using: .utf8)!,
        sharedInfo: any DataProtocol = Data()
    ) throws -> Data where H: HashFunction {
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: hashFunction,
            salt: protocolSalt,
            sharedInfo: sharedInfo,
            outputByteCount: 32
        )
        
        return symmetricKey.data
    }
    
    /// Creates `SymmetricKey` using private and public keys.
    static func x963DeriveSymmetricKey<H>(
        privateKey: P384.KeyAgreement.PrivateKey,
        publicKey: P384.KeyAgreement.PublicKey,
        using hashFunction: H.Type = SHA384.self,
        sharedInfo: any DataProtocol = Data()
    ) throws -> Data where H: HashFunction {
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let symmetricKey = sharedSecret.x963DerivedSymmetricKey(
            using: hashFunction,
            sharedInfo: sharedInfo,
            outputByteCount: 32
        )
        
        return symmetricKey.data
    }
}
