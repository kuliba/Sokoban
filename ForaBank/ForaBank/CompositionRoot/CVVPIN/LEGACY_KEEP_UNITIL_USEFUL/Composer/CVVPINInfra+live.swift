//
//  CVVPINInfra+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.10.2023.
//

import CVVPINServices
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
