//
//  CVVPINInfra+ext.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation
import GenericLoader

public extension CVVPINInfra {
    
    typealias RSAKeyPair = (publicKey: RSAPublicKey, privateKey: RSAPrivateKey)
    
    /// Create `CVVPINInfra` using `Store`s.
    @inlinable
    init(
        eventIDStore: any Store<EventID>,
        rsaKeyPairStore: any Store<RSAKeyPair>,
        sessionIDStore: any Store<SessionID>,
        sessionKeyWithEventStore: any Store<SessionKeyWithEvent>,
        symmetricKeyStore: any Store<SymmetricKey>,
        currentDate: @escaping () -> Date = Date.init
    ) {
        let eventIDLoader = LoaderOf(
            store: eventIDStore,
            currentDate: currentDate
        )
        let rsaKeyPairLoader = LoaderOf(
            store: rsaKeyPairStore,
            currentDate: currentDate
        )
        let sessionIDLoader = LoaderOf(
            store: sessionIDStore,
            currentDate: currentDate
        )
        let sessionKeyWithEventLoader = LoaderOf(
            store: sessionKeyWithEventStore,
            currentDate: currentDate
        )
        let symmetricKeyLoader = LoaderOf(
            store: symmetricKeyStore,
            currentDate: currentDate
        )
        
        self.init(
            loadEventID: eventIDLoader.load(completion:),
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            loadSessionID: sessionIDLoader.load(completion:),
            loadSessionKeyWithEvent: sessionKeyWithEventLoader.load(completion:),
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            saveSessionID: sessionIDLoader.saveAndForget,
            saveSymmetricKey: symmetricKeyLoader.saveAndForget
        )
    }
}

// MARK: - Adapter

public extension Loader {
    
    func saveAndForget(
        _ model: Model,
        _ validUntil: Date
    ) {
        save(model, validUntil: validUntil) { _ in }
    }
}
