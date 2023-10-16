//
//  CVVPINInfra+ext.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

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
        changePINProcess: @escaping ChangePINProcess,
        remoteCVVProcess: @escaping RemoteCVVProcess,
        processKey: @escaping ProcessKey,
        currentDate: @escaping () -> Date = Date.init
    ) {
        let eventIDLoader = GenericLoaderOf(
            store: eventIDStore,
            currentDate: currentDate
        )
        let rsaKeyPairLoader = GenericLoaderOf(
            store: rsaKeyPairStore,
            currentDate: currentDate
        )
        let sessionIDLoader = GenericLoaderOf(
            store: sessionIDStore,
            currentDate: currentDate
        )
        let sessionKeyWithEventLoader = GenericLoaderOf(
            store: sessionKeyWithEventStore,
            currentDate: currentDate
        )
        let symmetricKeyLoader = GenericLoaderOf(
            store: symmetricKeyStore,
            currentDate: currentDate
        )
        
        self.init(
            loadEventID: eventIDLoader.load(completion:),
            loadRSAKeyPair: rsaKeyPairLoader.load(completion:),
            loadSessionID: sessionIDLoader.load(completion:),
            loadSessionKeyWithEvent: sessionKeyWithEventLoader.load(completion:),
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            changePINProcess: changePINProcess,
            remoteCVVProcess: remoteCVVProcess,
            processKey: processKey,
            saveSessionID: sessionIDLoader.saveAndForget,
            saveSymmetricKey: symmetricKeyLoader.saveAndForget
        )
    }
}

public typealias GenericLoaderOf<Model> = GenericLoader<Model, Model>

public extension GenericLoaderOf where Local == Model {
    
    convenience init(
        store: any Store<Model>,
        currentDate: @escaping CurrentDate = Date.init
    ) {
        self.init(
            store: store,
            toModel: { $0 },
            toLocal: { $0 },
            currentDate: currentDate
        )
    }
}

// MARK: - Adapter

public extension GenericLoader {
    
    func saveAndForget(
        _ model: Model,
        _ validUntil: Date
    ) {
        save(model, validUntil: validUntil) { _ in }
    }
}
