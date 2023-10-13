//
//  CVVPINInfra+ext.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public extension CVVPINInfra {
    
    typealias RSAKeyPair = (publicKey: RSAPublicKey, privateKey: RSAPrivateKey)
    
    /// Create `CVVPINInfra` using `Store`s.
    init(
        eventIDStore: any Store<EventID>,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        sessionIDStore: any Store<SessionID>,
        loadSessionKeyWithEvent: @escaping LoadSessionKeyWithEvent,
        changePINProcess: @escaping ChangePINProcess,
        remoteCVVProcess: @escaping RemoteCVVProcess,
        processKey: @escaping ProcessKey,
        symmetricKeyStore: any Store<SymmetricKey>,
        currentDate: @escaping () -> Date = Date.init
    ) {
        let eventIDLoader = GenericLoaderOf(store: eventIDStore, currentDate: currentDate)
        let sessionIDLoader = GenericLoaderOf(store: sessionIDStore, currentDate: currentDate)
        let symmetricKeyLoader = GenericLoaderOf(store: symmetricKeyStore, currentDate: currentDate)
        
        self.init(
            loadEventID: eventIDLoader.load(completion:),
            loadRSAKeyPair: loadRSAKeyPair,
            loadSessionID: sessionIDLoader.load(completion:),
            loadSessionKeyWithEvent: loadSessionKeyWithEvent,
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            changePINProcess: changePINProcess,
            remoteCVVProcess: remoteCVVProcess,
            processKey: processKey,
            saveSessionID: sessionIDLoader.saveAndForget,
            saveSymmetricKey: symmetricKeyLoader.saveAndForget
        )
    }
}

typealias GenericLoaderOf<Model> = GenericLoader<Model, Model>

extension GenericLoaderOf where Local == Model {
    
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

extension GenericLoader {
    
    func saveAndForget(
        _ model: Model,
        _ validUntil: Date
    ) {
        save(model, validUntil: validUntil) { _ in }
    }
}
