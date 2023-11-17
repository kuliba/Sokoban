//
//  MakeComposerInfraTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import CVVPINServices
import XCTest

class MakeComposerInfraTests: XCTestCase {
    
    // MARK: - API errors
    
    typealias ChangePINAPIError = ResponseMapper.ChangePINMappingError
    typealias KeyServiceAPIError = ResponseMapper.KeyExchangeMapperError
    typealias ShowCVVAPIError = ResponseMapper.ShowCVVMapperError

    // MARK: - errors

    typealias PINError = ChangePINError<ChangePINAPIError>

    // MARK: - results
    
    typealias KeyExchangeResult = Result<Void, KeyExchangeError<KeyServiceAPIError>>
    
    // MARK: - components
    
    typealias Composer<SessionID> = CVVPINComposer<CardID, ChangePINAPIError, CVV, ECDHPublicKey, ECDHPrivateKey, EventID, KeyServiceAPIError, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, ShowCVVAPIError, SymmetricKey>
    typealias Infra<SessionID> = CVVPINInfra<EventID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    typealias Remote<SessionID> = CVVPINRemote<RemoteCVV, SessionID, ChangePINAPIError, KeyServiceAPIError, ShowCVVAPIError>
    
    typealias PINChanger<SessionID> = ChangePINService<ChangePINAPIError, CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    
    // MARK: - loaders
    
    typealias EventIDLoaderSpy = LoaderSpyOf<EventID>
    typealias RSAKeyPairLoaderSpy = LoaderSpyOf<RSAKeyPair>
    typealias RSAPrivateKeyLoaderSpy = LoaderSpyOf<RSAPrivateKey>
    typealias SessionIDLoaderSpy<SessionID> = LoaderSpyOf<SessionID>
    typealias SessionKeyWithEventLoaderSpy = LoaderSpyOf<SessionKeyWithEvent>
    typealias SymmetricKeyLoaderSpy = LoaderSpyOf<SymmetricKey>
    
    // MARK: - caches
    
    typealias SessionIDCache<SessionID> = CacheSpyOf<(SessionID, Date)>
    typealias SymmetricKeyCache = CacheSpyOf<(SymmetricKey, Date)>
    
    func makeCVVPINInfra<T>(
        _ t: T.Type = T.self,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        infra: Infra<T>,
        eventIDLoader: EventIDLoaderSpy,
        keyPairLoader: RSAKeyPairLoaderSpy,
        sessionIDCache: SessionIDCache<T>,
        sessionIDLoader: SessionIDLoaderSpy<T>,
        sessionKeyWithEventLoader: SessionKeyWithEventLoaderSpy,
        symmetricKeyCache: SymmetricKeyCache,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let eventIDLoader = EventIDLoaderSpy()
        let keyPairLoader = RSAKeyPairLoaderSpy()
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
            saveSessionID: { sessionIDCache.save(($0, $1)) { _ in }},
            saveSymmetricKey: { symmetricKeyCache.save(($0, $1)) { _ in }}
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(changePINService, file: file, line: line)
        
        return (infra, eventIDLoader, keyPairLoader, sessionIDCache, sessionIDLoader, sessionKeyWithEventLoader, symmetricKeyCache, symmetricKeyLoader)
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
        symmetricKeyStore: StoreSpy<SymmetricKey>
    ) {
        let eventIDStore = StoreSpy<EventID>()
        let rsaKeyPairStore = StoreSpy<RSAKeyPair>()
        let sessionIDStore = StoreSpy<T>()
        let sessionKeyWithEventStore = StoreSpy<SessionKeyWithEvent>()
        let symmetricKeyStore = StoreSpy<SymmetricKey>()
        
        let infra = Infra<T>(
            eventIDStore: eventIDStore,
            rsaKeyPairStore: rsaKeyPairStore,
            sessionIDStore: sessionIDStore,
            sessionKeyWithEventStore: sessionKeyWithEventStore,
            symmetricKeyStore: symmetricKeyStore,
            currentDate: currentDate
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(eventIDStore, file: file, line: line)
        
        return (infra, eventIDStore, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, symmetricKeyStore)
    }
    
    // MARK: - services
    
    typealias PINChangeResult = Result<Void, ChangePINAPIError>
    typealias PINChangeServiceSpy<SessionID> = ServiceSpy<PINChangeResult, (SessionID, Data)>
    typealias ShowCVVServiceSpy<SessionID> = RemoteServiceSpy<RemoteCVV, ShowCVVAPIError, (SessionID, Data)>
    typealias KeyServiceSpy = RemoteServiceSpy<PublicKeyAuthenticationResponse, KeyServiceAPIError, Data>

    func makeCVVPRemote<T>(
        _ t: T.Type = T.self,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        remote: Remote<T>,
        showCVVService: ShowCVVServiceSpy<T>,
        keyService: KeyServiceSpy,
        changePINService: PINChangeServiceSpy<T>
    ) {
        let showCVVService = ShowCVVServiceSpy<T>()
        let keyService = KeyServiceSpy()
        let changePINService = PINChangeServiceSpy<T>()
        
        let remote = Remote(
            changePINProcess: changePINService.process(_:completion:),
            remoteCVVProcess: showCVVService.process(_:completion:),
            keyAuthProcess: keyService.process(_:completion:)
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(changePINService, file: file, line: line)
        
        return (remote, showCVVService, keyService, changePINService)
    }
    
    func makeCVVPINRemote<T>(
        _ t: T.Type = T.self,
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        remote: Remote<T>,
        changePINService: PINChangeServiceSpy<T>,
        showCVVService: ShowCVVServiceSpy<T>,
        keyService: KeyServiceSpy
    ) {
        let changePINService = PINChangeServiceSpy<T>()
        let showCVVService = ShowCVVServiceSpy<T>()
        let keyService = KeyServiceSpy()
        
        let remote = Remote<T>(
            changePINProcess: changePINService.process(_:completion:),
            remoteCVVProcess: showCVVService.process(_:completion:),
            keyAuthProcess: keyService.process(_:completion:)
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(eventIDStore, file: file, line: line)
        
        return (remote, changePINService, showCVVService, keyService)
    }
}
