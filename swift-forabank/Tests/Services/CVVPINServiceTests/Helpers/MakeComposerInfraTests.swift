//
//  MakeComposerInfraTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import CVVPINService
import XCTest

class MakeComposerInfraTests: XCTestCase {
    
    typealias Infra<SessionID> = CVVPINInfra<CardID, EventID, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    typealias PINChanger<SessionID> = ChangePINService<CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    typealias PINError<SessionID> = PINChanger<SessionID>.Error
    
    typealias PINChangeServiceSpy<SessionID> = ServiceSpyOf<PINChanger<SessionID>.Error?>
    typealias CVVServiceSpy = RemoteServiceSpyOf<RemoteCVV>
    typealias EventIDLoaderSpy = LoaderSpyOf<EventID>
    typealias KeyServiceSpy = RemoteServiceSpyOf<PublicKeyAuthenticationResponse>
    typealias RSAKeyPairLoaderSpy = LoaderSpyOf<RSAKeyPair>
    typealias RSAPrivateKeyLoaderSpy = LoaderSpyOf<RSAPrivateKey>
    typealias SessionIDCache<SessionID> = CacheSpyOf<(SessionID, Date)>
    typealias SessionIDLoaderSpy<SessionID> = LoaderSpyOf<SessionID>
    typealias SessionKeyWithEventLoaderSpy = LoaderSpyOf<SessionKeyWithEvent>
    typealias SymmetricKeyCache = CacheSpyOf<(SymmetricKey, Date)>
    typealias SymmetricKeyLoaderSpy = LoaderSpyOf<SymmetricKey>
    
    func makeCVVPINInfra<T>(
        _ t: T.Type = T.self,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        infra: Infra<T>,
        cvvService: CVVServiceSpy,
        eventIDLoader: EventIDLoaderSpy,
        keyPairLoader: RSAKeyPairLoaderSpy,
        keyService: KeyServiceSpy,
        pinService: PINChangeServiceSpy<T>,
        sessionIDCache: SessionIDCache<T>,
        sessionIDLoader: SessionIDLoaderSpy<T>,
        sessionKeyWithEventLoader: SessionKeyWithEventLoaderSpy,
        symmetricKeyCache: SymmetricKeyCache,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let cvvService = CVVServiceSpy()
        let eventIDLoader = EventIDLoaderSpy()
        let keyPairLoader = RSAKeyPairLoaderSpy()
        let keyService = KeyServiceSpy()
        let pinService = ServiceSpyOf<PINChanger<T>.Error?>()
        let sessionIDCache = SessionIDCache<T>()
        let sessionIDLoader = SessionIDLoaderSpy<T>()
        let sessionKeyWithEventLoader = SessionKeyWithEventLoaderSpy()
        let symmetricKeyCache = SymmetricKeyCache()
        let symmetricKeyLoader = SymmetricKeyLoaderSpy()
        
        let infra = Infra(
            loadEventID: eventIDLoader.load(completion:),
            loadRSAKeyPair: keyPairLoader.load(completion:),
            loadSessionID: sessionIDLoader.load(completion:),
            loadSessionKeyWithEvent: sessionKeyWithEventLoader.load(completion:),
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            changePINProcess: pinService.process(_:completion:),
            remoteCVVProcess: cvvService.process(_:completion:),
            processKey: keyService.process(_:completion:),
            saveSessionID: { sessionIDCache.save(($0, $1)) { _ in }},
            saveSymmetricKey: { symmetricKeyCache.save(($0, $1)) { _ in }}
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(changePINService, file: file, line: line)
        
        return (infra, cvvService, eventIDLoader, keyPairLoader, keyService, pinService, sessionIDCache, sessionIDLoader, sessionKeyWithEventLoader, symmetricKeyCache, symmetricKeyLoader)
    }
    
    
    func makeCVVPINInfra<T>(
        _ t: T.Type = T.self,
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        infra: Infra<T>,
        eventIDStore: StoreSpy<EventID>,
        rsaKeyPairStore: StoreSpy<RSAKeyPair>,
        sessionIDStore: StoreSpy<T>,
        sessionKeyWithEventStore: StoreSpy<SessionKeyWithEvent>,
        symmetricKeyStore: StoreSpy<SymmetricKey>,
        pinService: ServiceSpyOf<PINChanger<T>.Error?>,
        remoteCVVService: RemoteServiceSpyOf<RemoteCVV>,
        keyService: RemoteServiceSpyOf<PublicKeyAuthenticationResponse>
    ) {
        let eventIDStore = StoreSpy<EventID>()
        let rsaKeyPairStore = StoreSpy<RSAKeyPair>()
        let sessionIDStore = StoreSpy<T>()
        let sessionKeyWithEventStore = StoreSpy<SessionKeyWithEvent>()
        let pinService = ServiceSpyOf<PINChanger<T>.Error?>()
        let remoteCVVService = RemoteServiceSpyOf<RemoteCVV>()
        let keyService = RemoteServiceSpyOf<PublicKeyAuthenticationResponse>()
        let symmetricKeyStore = StoreSpy<SymmetricKey>()
        
        let infra = Infra<T>(
            eventIDStore: eventIDStore,
            rsaKeyPairStore: rsaKeyPairStore,
            sessionIDStore: sessionIDStore,
            sessionKeyWithEventStore: sessionKeyWithEventStore,
            symmetricKeyStore: symmetricKeyStore,
            changePINProcess: pinService.process(_:completion:),
            remoteCVVProcess: remoteCVVService.process(_:completion:),
            processKey: keyService.process(_:completion:),
            currentDate: currentDate
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(eventIDStore, file: file, line: line)
        
        return (infra, eventIDStore, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, symmetricKeyStore, pinService, remoteCVVService, keyService)
    }
}
