//
//  CVVPINInfra.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public struct CVVPINInfra<CardID, EventID, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey> {
    
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
    
    public typealias PinChanger = ChangePINService<CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    public typealias ChangePINCompletion = (PinChanger.Error?) -> Void
    public typealias ChangePINProcess = (Data, @escaping ChangePINCompletion) -> Void
    
    public typealias RemoteCVVServiceDomain = RemoteServiceDomain<Data, RemoteCVV, Error>
    public typealias RemoteCVVProcess = RemoteCVVServiceDomain.AsyncGet
    
    public typealias Response = PublicKeyAuthenticationResponse
    public typealias KeyServiceDomain = RemoteServiceDomain<Data, Response, Error>
    public typealias ProcessKey = KeyServiceDomain.AsyncGet
    
    public typealias CVVServiceDomain = RemoteServiceDomain<Data, RemoteCVV, Error>
    public typealias ProcessCVV = CVVServiceDomain.AsyncGet
    
    public typealias SaveSessionID = (SessionID, Date) -> Void
    public typealias SaveSymmetricKey = (SymmetricKey, Date) -> Void
    
    let loadEventID: LoadEventID
    let loadRSAKeyPair: LoadRSAKeyPair
    let loadRSAPrivateKey: LoadRSAPrivateKey
    let loadSessionID: LoadSessionID
    let loadSessionKeyWithEvent: LoadSessionKeyWithEvent
    let loadSymmetricKey: LoadSymmetricKey
    let changePINProcess: ChangePINProcess
    let remoteCVVProcess: RemoteCVVProcess
    let processKey: ProcessKey
    let saveSessionID: SaveSessionID
    let saveSymmetricKey: SaveSymmetricKey
    
    public init(
        loadEventID: @escaping LoadEventID,
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadSessionID: @escaping LoadSessionID,
        loadSessionKeyWithEvent: @escaping LoadSessionKeyWithEvent,
        loadSymmetricKey: @escaping LoadSymmetricKey,
        changePINProcess: @escaping ChangePINProcess,
        remoteCVVProcess: @escaping RemoteCVVProcess,
        processKey: @escaping ProcessKey,
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
        self.changePINProcess = changePINProcess
        self.remoteCVVProcess = remoteCVVProcess
        self.processKey = processKey
        self.saveSessionID = saveSessionID
        self.saveSymmetricKey = saveSymmetricKey
    }
}
