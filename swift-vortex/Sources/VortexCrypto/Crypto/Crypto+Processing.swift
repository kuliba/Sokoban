//
//  Crypto+Processing.swift
//  
//
//  Created by Igor Malyarov on 25.10.2023.
//

import Foundation

public extension Crypto {
    
    /// Encrypts given data using processing key and padding.
    static func processingEncrypt(
        _ data: Data,
        padding: SecPadding = .PKCS1
    ) throws -> Data {
        
        try Crypto.encryptWithRSAKey(
            data,
            publicKey: Crypto.processingKey(),
            padding: padding
        )
    }
    
    /// Returns `publicKey` from bundle certificate.
    static func processingKey() throws -> SecKey {
        
        try extractPublicKey(fromPEM: String(contentsOf: processingPemURL))
    }
    
    static func extractPublicKey(
        fromPEM pemString: String,
        keySize: Int = 4096
    ) throws -> SecKey {

        let pemHeader = "-----BEGIN PUBLIC KEY-----"
        let pemFooter = "-----END PUBLIC KEY-----"
        
        guard let headerRange = pemString.range(of: pemHeader),
              let footerRange = pemString.range(of: pemFooter)
        else {
            throw PEMError.invalidPEMStructure
        }
        
        let keyRange = pemString.index(after: headerRange.upperBound)..<footerRange.lowerBound
        let base64String = pemString[keyRange].filter { !$0.isWhitespace }
        
        guard let keyData = Data(base64Encoded: String(base64String))
        else {
            throw PEMError.conversionFailure
        }
        
        let options: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: keySize,
            kSecReturnPersistentRef as String: true
        ]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(keyData as CFData, options as CFDictionary, &error)
        else {
            throw error!.takeRetainedValue() as Swift.Error
        }
        
        return key
    }
    
    enum PEMError: Swift.Error {
        case invalidPEMStructure
        case conversionFailure
        case unexpectedKeyType
    }
}
