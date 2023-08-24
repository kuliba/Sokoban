//
//  Crypto+P384.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import CryptoKit
import Foundation

public extension Crypto {
    
    static func generateP384KeyPair(
    ) -> P384KeyAgreementDomain.KeyPair {
        
        let privateKey = P384.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        
        return (privateKey, publicKey)
    }
    
    /// Create `P384.KeyAgreement.PrivateKey` from a given string using `derRepresentation`.
    static func makeP384PrivateKey(
        from string: String
    ) throws -> P384KeyAgreementDomain.PrivateKey {
        
        guard let data = Data(base64Encoded: string)
        else {
            throw Error.base64StringEncodedData(string)
        }
        
        return try P384.KeyAgreement.PrivateKey(derRepresentation: data)
    }
    
    /// Uses `rawRepresentation`.
    static func decrypt384PublicKey(
        from string: String,
        with secKey: SecKey,
        advancedBy amount: Int
    ) throws -> P384KeyAgreementDomain.PublicKey {
        
        let decryptedData = try decrypt(string, with: .rsaEncryptionRaw, using: secKey)
        
        // MARK: - Advance!
        let amount = min(amount, decryptedData.count)
        let advanced = decryptedData.advanced(by: amount)
        
        let publicKey = try P384.KeyAgreement.PublicKey(rawRepresentation: advanced)
        
        return publicKey
    }
    
    static func sharedSecret(
        privateKey: P384KeyAgreementDomain.PrivateKey,
        publicKey: P384KeyAgreementDomain.PublicKey,
        length: Int? = nil
    ) throws -> Data {
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let data = sharedSecret.data
        
        return data.prefix(length ?? data.count)
    }
}
