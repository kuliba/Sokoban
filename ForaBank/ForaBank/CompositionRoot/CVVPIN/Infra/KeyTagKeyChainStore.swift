//
//  KeyTagKeyChainStore.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.10.2023.
//

import Foundation
import ForaCrypto
import KeyChainStore

typealias KeyTagKeyChainStore<Key> = KeyChainStore<KeyTag, Key>

enum KeyTag: String {
    
    case cvvPINActivation
    case rsa
}

extension KeyTagKeyChainStore
where Key == String {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: { .init($0.utf8) },
            key: {
                try .init(data: $0, encoding: .utf8).get(orThrow: DataToStringConversionError())
            }
        )
    }
    
    struct DataToStringConversionError: Swift.Error {}
}

extension KeyTagKeyChainStore
where Key == SecKey {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: { try $0.rawRepresentation },
            key: ForaCrypto.Crypto.createPrivateSecKey
        )
    }
}

extension KeyTagKeyChainStore
where Key == RSADomain.KeyPair {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: { try $0.privateKey.key.rawRepresentation },
            key: { data in
                
                let privateKey = try ForaCrypto.Crypto.createPrivateSecKey(from: data)
                let publicKey = try ForaCrypto.Crypto.extractPublicKey(fromPrivateKey: privateKey)
                
                return (privateKey: .init(key: privateKey), publicKey: .init(key: publicKey))
            }
        )
    }
}

private extension ForaCrypto.Crypto {
    
    static func createPrivateSecKey(
        from data: Data
    ) throws -> SecKey {
        
        try createSecKey(
            from: data,
            keyType: .rsa,
            keyClass: .privateKey,
            keySize: .bits4096
        )
    }
    
    static func extractPublicKey(
        fromPrivateKey privateKey: SecKey
    ) throws -> SecKey {
        
        try SecKeyCopyPublicKey(privateKey).get(orThrow: Error.extractPublicKeyFromPrivateKeyFailure)
    }
}

extension KeyTagKeyChainStore
where Key == SymmetricKey {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: { $0.rawValue},
            key: { try .init(rawValue: $0).get(orThrow: RawRepresentationError()) }
        )
    }
}

extension Optional {
    
    func get(orThrow error: Error) throws -> Wrapped {
        
        guard let wrapped = self else { throw error }
        
        return wrapped
    }
}

struct RawRepresentationError: Swift.Error {}
