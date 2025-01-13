//
//  Crypto+Transport.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import CryptoKit
import Foundation

public extension Crypto {
    
    /// Create `P384.KeyAgreement.PublicKey` using `derRepresentation` from a string that is decrypted with Transport Key.
    static func transportDecryptP384PublicKey(
        from string: String
    ) throws -> P384KeyAgreementDomain.PublicKey {
        
        let decryptedData = try transportDecrypt(string)
        let derRepresentation = decryptedData.dropFirst(392)
        
        return try .init(derRepresentation: derRepresentation)
    }
    
    /// Encrypts given data using transport key.
    static func transportEncrypt(
        _ data: Data
    ) throws -> Data {
        
        try encrypt(
            data: data,
            withPublicKey: transportKey(),
            algorithm: .rsaEncryptionRaw
        )
    }
    
    /// Encrypts given data using transport key and padding.
    static func transportEncrypt(
        _ data: Data,
        padding: SecPadding = .PKCS1
    ) throws -> Data {
        
        try encryptWithRSAKey(
            data,
            publicKey: transportKey(),
            padding: padding
        )
    }
    
    /// Decrypts given string using transport key.
    static func transportDecrypt(
        _ string: String
    ) throws -> Data {
        
        try decrypt(
            string,
            with: .rsaEncryptionRaw,
            using: transportKey()
        )
    }
    
    /// Uses `rawRepresentation`.
    static func transportDecryptP384PublicKey(
        _ string: String
    ) throws -> P384KeyAgreementDomain.PublicKey {
        
        try decrypt384PublicKey(
            from: string,
            with: transportKey(),
            advancedBy: 416
        )
    }
    
    /// Returns `publicKey` from bundle certificate.
    static func transportKey() throws -> SecKey {
        
        try secKey(fromCertURL: publicCrtURL)
    }
}
