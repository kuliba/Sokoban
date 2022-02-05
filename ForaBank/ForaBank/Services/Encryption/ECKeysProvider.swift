//
//  ECKeysProvider.swift
//  ForaBank
//
//  Created by Max Gribov on 21.01.2022.
//

import Foundation
import Security

struct ECKeysProvider: EncryptionKeysProvider {
    
    func getPublicKey() throws -> SecKey {
        
        let privateKey = try getPrivateKey()
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw ECKeysProviderError.publicKeyGenerationFailed
        }
        
        return publicKey
    }
    
    func getPrivateKey() throws -> SecKey {
        
        var item: CFTypeRef?
        
        // search for private key in keychain
        switch SecItemCopyMatching(getquery, &item) {
        case errSecSuccess:
            // key found, just return it
            return (item as! SecKey)
            
        case errSecItemNotFound:
            // key not found, try to create new one
            var error: Unmanaged<CFError>?
            if let privateKey = SecKeyCreateRandomKey(attributes, &error)  {
                
                return privateKey
                
            } else {
                
                throw ECKeysProviderError.privateKeyGenerationFailed(error?.takeRetainedValue())
            }
            
        case let status:
            // keychain internal error
            throw ECKeysProviderError.keychainReadFailed(status)
        }
    }

    func deletePrivateKey() throws {
        
        switch SecItemDelete(getquery) {
        case errSecSuccess: return
        case let status:
            throw ECKeysProviderError.privateKeyDetelionFailed(status)
        }
    }
}

//MARK: - Helpers

extension ECKeysProvider {
    
    func publicKeyData() throws -> Data {
        
        let publicKey = try getPublicKey()
        var error: Unmanaged<CFError>?
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?  else {
            throw ECKeysProviderError.publicKeyDataConversionFailed(error?.takeRetainedValue())
        }
        
        return publicKeyData
    }
    
    func publicKey(from data: Data) throws -> SecKey {
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(data as CFData, options, &error) else {
            throw ECKeysProviderError.publicKeyFromDataFailed(error?.takeRetainedValue())
        }
        
        return key
    }
}

//MARK: - Parameters

extension ECKeysProvider {

    /// Encryptyon algorithm
    //TODO: check algorithm on server
    var algorithm: SecKeyAlgorithm { .eciesEncryptionStandardX963SHA384AESGCM }

    /// Atrtiburtes for generating local keys pair
    var attributes: CFDictionary {
        
        return [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                kSecAttrKeySizeInBits as String: 384,
                kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: true,
                                                kSecAttrApplicationTag as String: tag]] as CFDictionary
    }
    
    /// External public key options
    var options: CFDictionary {
        
        return [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String : 384] as CFDictionary
    }
    
    /// Query parameters to search private key in keychain
    var getquery: CFDictionary {
        
        return [kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: tag,
                kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                kSecReturnRef as String: true] as CFDictionary
    }
    
    /// Private key tag
    var tag: Data { "ru.forabank.sense".data(using: .utf8)! }
}

//MARK: - Types

enum ECKeysProviderError: Error {
    
    case keychainReadFailed(OSStatus)
    case privateKeyGenerationFailed(Error?)
    case publicKeyGenerationFailed
    case publicKeyDataConversionFailed(Error?)
    case publicKeyFromDataFailed(Error?)
    case privateKeyDetelionFailed(OSStatus)
    case unableEncryptWithAlgorithm(SecKeyAlgorithm)
    case encryptionFailed(Error?)
    case unableDecryptWithAlgorithm(SecKeyAlgorithm)
    case unableDecrypthDataSizeExceedsLimit
    case decryptionFailed(Error?)
}

