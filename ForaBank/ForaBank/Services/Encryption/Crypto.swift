//
//  Crypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import Foundation

/// A namespace.
enum Crypto {}

extension Crypto {
    
    static func rsaPKCS1Encrypt(
        data: Data,
        withPublicKey key: SecKey
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let encrypted = SecKeyCreateEncryptedData(key, .rsaEncryptionPKCS1, data as CFData, &error) as Data?
        else {
            throw EncryptionError.publicKeyEncryptionFailure(error?.takeRetainedValue())
        }
        
        return encrypted
    }
    
    enum EncryptionError: Error {
        
        case publicKeyEncryptionFailure(Error?)
    }
}

extension Crypto {
    
    // TODO: generalise with KeySizeInBits as a parameter (enum with fixed values)
    static func generateRSA4096BitKeys() throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 4096,
            kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: false]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey)
        else {
            throw KeyGenerationError.rsa4096BitKeysGenerationFailure(error?.takeRetainedValue())
        }
        
        return (privateKey, publicKey)
    }
    
    enum KeyGenerationError: Error {
        
        case rsa4096BitKeysGenerationFailure(Error?)
    }
}
