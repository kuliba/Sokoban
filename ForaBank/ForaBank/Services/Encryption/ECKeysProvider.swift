//
//  ECKeysProvider.swift
//  Vortex
//
//  Created by Max Gribov on 21.01.2022.
//

import Foundation
import Security

struct ECKeysProvider: EncryptionKeysProvider {
 
    func generateKeysPair() throws -> EncryptionKeysPair {
        
        var publicKey, privateKey: SecKey?
        
        let parameters: [String : Any] = [
            kSecAttrKeySizeInBits as String: 384,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
            kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: false]
        ]
        
        SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
        
        guard let publicKey = publicKey, let privateKey = privateKey else {
            throw ECKeysProviderError.unableGenerateKeysPair
        }
        
        return .init(publicKey: publicKey, privateKey: privateKey)
    }
}

//MARK: - Types

enum ECKeysProviderError: Error {
    
    case unableGenerateKeysPair
}

