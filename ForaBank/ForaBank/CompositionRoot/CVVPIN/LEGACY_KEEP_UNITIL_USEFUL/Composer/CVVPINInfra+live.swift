//
//  CVVPINInfra+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.10.2023.
//

import CVVPINServices
import ForaCrypto
import Foundation
import KeyChainStore

extension CVVPINInfra
where RSAPublicKey == SecKey,
      RSAPrivateKey == SecKey,
      SymmetricKey == ForaBank.SymmetricKey {
    
    static func live(
        httpClient: HTTPClient,
        currentDate: @escaping () -> Date = Date.init
    ) -> Self {
        
        // persistent stores
        let persistentSymmetricKeyStore = KeyTagKeyChainStore<SymmetricKey>(keyTag: .cvvPIN)
        
        let persistentRSAKeyPairStore = KeyTagKeyChainStore<RSAKeyPairDomain.KeyPair>(keyTag: .rsa)
        
        // ephemeral stores
        let eventIDStore = InMemoryStore<EventID>()
        let sessionIDStore = InMemoryStore<SessionID>()
        #warning("looks like possible duplication ?")
        let sessionKeyWithEventStore = InMemoryStore<SessionKeyWithEvent>()
        
        #warning("there is `loadRSAKeyPair`, but where is `save`?")
        
        return .init(
            eventIDStore: eventIDStore,
            rsaKeyPairStore: persistentRSAKeyPairStore,
            sessionIDStore: sessionIDStore,
            sessionKeyWithEventStore: sessionKeyWithEventStore,
            symmetricKeyStore: persistentSymmetricKeyStore,
            currentDate: currentDate
        )
    }
}

extension KeyTagKeyChainStore
where Key == CVVPINInfra<EventID, SecKey, SecKey, SessionID, ForaBank.SymmetricKey>.RSAKeyPairDomain.KeyPair {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: { try $0.privateKey.rawRepresentation },
            key: { data in
                
                let privateKey = try ForaCrypto.Crypto.createPrivateSecKey(from: data)
                let publicKey = try ForaCrypto.Crypto.extractPublicKey(fromPrivateKey: privateKey)
                
                return (publicKey: publicKey, privateKey: privateKey)
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
