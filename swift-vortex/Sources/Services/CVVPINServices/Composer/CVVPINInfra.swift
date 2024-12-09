//
//  CVVPINInfra.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public struct CVVPINInfra<EventID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey> {
    
    // MARK: - Loaders
    
    public typealias EventIDDomain = DomainOf<EventID>
    public typealias LoadEventID = EventIDDomain.AsyncGet
    
    public typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    public typealias LoadRSAKeyPair = RSAKeyPairDomain.AsyncGet
    
    public typealias RSAPrivateKeyDomain = DomainOf<RSAPrivateKey>
    public typealias LoadRSAPrivateKey = RSAPrivateKeyDomain.AsyncGet
    
    public typealias SessionIDDomain = DomainOf<SessionID>
    public typealias LoadSessionID = SessionIDDomain.AsyncGet
    
    public typealias SessionKeyWithEventLoaderDomain = DomainOf<SessionKeyWithEvent>
    public typealias LoadSessionKeyWithEvent = SessionKeyWithEventLoaderDomain.AsyncGet
    
    public typealias SymmetricKeyDomain = DomainOf<SymmetricKey>
    public typealias LoadSymmetricKey = SymmetricKeyDomain.AsyncGet
    
    // MARK: - Caches
    
    public typealias SaveSessionID = (SessionID, Date) -> Void
    public typealias SaveSymmetricKey = (SymmetricKey, Date) -> Void
    
    // loaders
    public let loadEventID: LoadEventID
    public let loadRSAKeyPair: LoadRSAKeyPair
    public let loadRSAPrivateKey: LoadRSAPrivateKey
    public let loadSessionID: LoadSessionID
    public let loadSessionKeyWithEvent: LoadSessionKeyWithEvent
    public let loadSymmetricKey: LoadSymmetricKey
    // caches
    public let saveSessionID: SaveSessionID
    public let saveSymmetricKey: SaveSymmetricKey
    
    public init(
        loadEventID: @escaping LoadEventID,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadSessionID: @escaping LoadSessionID,
        loadSessionKeyWithEvent: @escaping LoadSessionKeyWithEvent,
        loadSymmetricKey: @escaping LoadSymmetricKey,
        saveSessionID: @escaping SaveSessionID,
        saveSymmetricKey: @escaping SaveSymmetricKey
    ) {
        self.loadEventID = loadEventID
        self.loadRSAKeyPair = loadRSAKeyPair
        self.loadRSAPrivateKey = { [loadRSAKeyPair] completion in
            
            loadRSAKeyPair { result in
                
                completion(.init {
                    
                    try result.get().privateKey
                })
            }
        }
        self.loadSessionID = loadSessionID
        self.loadSessionKeyWithEvent = loadSessionKeyWithEvent
        self.loadSymmetricKey = loadSymmetricKey
        self.saveSessionID = saveSessionID
        self.saveSymmetricKey = saveSymmetricKey
    }
}
