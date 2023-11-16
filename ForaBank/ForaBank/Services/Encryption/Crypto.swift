//
//  Crypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import CryptoKit
import Foundation

/// A namespace.
enum Crypto {}

extension Crypto {
    
    enum CryptoError: Error {
        
        case publicTransportKeyExternalRepresentationFailure
        case base64StringDecodingFailure
        case serverPublicKeyDataDecryptionFailure(Error?)
        case serverPublicKeyCreationFromDataFailure(Error?)
    }
}

extension Crypto {
    
    // TODO: generalise with KeySizeInBits as a parameter (enum with fixed values)
    static func createRandomRSA4096BitKeys() throws -> (
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
        // TODO: Generalise error too
        case rsa4096BitKeysGenerationFailure(Error?)
    }
}

extension Crypto {
    
    static func serverPublicKey(
        from serverPublicKeyEncryptedString: String,
        using publicTransportKey: SecKey
    ) throws -> SecKey {
        
        do {
            guard let serverPublicKeyEncryptedData = Data(base64Encoded: serverPublicKeyEncryptedString, options: .ignoreUnknownCharacters)
            else {
                throw CryptoError.base64StringDecodingFailure
            }
            
            var error: Unmanaged<CFError>? = nil
            guard let publicTransportKeyData = SecKeyCopyExternalRepresentation(publicTransportKey, &error) as? Data
            else {
                throw CryptoError.publicTransportKeyExternalRepresentationFailure
            }
            
            let symmetricKey = CryptoKit.SymmetricKey(data: publicTransportKeyData)
            dump(symmetricKey)
           // let sealedBox = try CryptoKit.AES.GCM.SealedBox(combined: serverPublicKeyEncryptedData)
            let sealedBox = try CryptoKit.AES.GCM.SealedBox(
                nonce: .init(data: "nonce".data),
                ciphertext: serverPublicKeyEncryptedData,
                tag: "tag".data
            )
            let serverPublicKeyDecryptedData = try CryptoKit.AES.GCM.open(sealedBox, using: symmetricKey)
            
            //        guard let serverPublicKeyDecryptedData = SecKeyCreateDecryptedData(publicTransportKey, .rsaEncryptionRaw,  serverPublicKeyEncryptedData as CFData, &error) as Data?
            //        else {
            //            throw CryptoError.serverPublicKeyDataDecryptionFailure(error?.takeRetainedValue())
            //        }
            
            let parameters = [
                kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String: 384,
                SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32
            ] as [String : Any]
            
            //        let withoutDERHeader = serverPublicKeyDecryptedData.advanced(by: 159) as CFData
            
            guard let serverPublicKey = SecKeyCreateWithData(serverPublicKeyDecryptedData as CFData, parameters as CFDictionary, &error)
            else {
                throw CryptoError.serverPublicKeyCreationFromDataFailure(error?.takeRetainedValue())
            }
            
            return serverPublicKey
        } catch {
            throw error
        }
    }
}
