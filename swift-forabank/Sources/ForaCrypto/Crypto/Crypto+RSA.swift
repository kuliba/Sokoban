//
//  Crypto+RSA.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import Foundation

public extension Crypto {
    
    static func rsaPKCS1Encrypt(
        data: Data,
        withPublicKey key: SecKey,
        algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let encrypted = SecKeyCreateEncryptedData(key, algorithm, data as CFData, &error) as Data?
        else {
            throw Error.encryptionFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return encrypted
    }
    
    static func rsaPKCS1Decrypt(
        data: Data,
        withPrivateKey key: SecKey,
        algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let decrypted = SecKeyCreateDecryptedData(key, algorithm, data as CFData, &error) as Data?
        else {
            throw Error.decryptionFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return decrypted
    }
}
