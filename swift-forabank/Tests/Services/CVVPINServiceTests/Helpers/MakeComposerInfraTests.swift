//
//  MakeComposerInfraTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import CVVPINService
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
    typealias Infra<SessionID> = CVVPINInfra<CardID, ChangePINAPIError, EventID, KeyServiceAPIError, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, ShowCVVAPIError, SymmetricKey>
    
    typealias PINChanger<SessionID> = ChangePINService<ChangePINAPIError, CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    
    // MARK: - services
    
    typealias PINChangeServiceSpy<SessionID> = ServiceSpyOf<ChangePINAPIError?>
    typealias CVVServiceSpy = RemoteServiceSpy<RemoteCVV, ShowCVVAPIError, Data>
    typealias KeyServiceSpy = RemoteServiceSpy<PublicKeyAuthenticationResponse, KeyServiceAPIError, Data>

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
        let pinService = PINChangeServiceSpy<T>()
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
        pinService: PINChangeServiceSpy<T>,
        cvvService: CVVServiceSpy,
        keyService: KeyServiceSpy
    ) {
        let eventIDStore = StoreSpy<EventID>()
        let rsaKeyPairStore = StoreSpy<RSAKeyPair>()
        let sessionIDStore = StoreSpy<T>()
        let sessionKeyWithEventStore = StoreSpy<SessionKeyWithEvent>()
        let pinService = PINChangeServiceSpy<T>()
        let cvvService = CVVServiceSpy()
        let keyService = KeyServiceSpy()
        let symmetricKeyStore = StoreSpy<SymmetricKey>()
        
        let infra = Infra<T>(
            eventIDStore: eventIDStore,
            rsaKeyPairStore: rsaKeyPairStore,
            sessionIDStore: sessionIDStore,
            sessionKeyWithEventStore: sessionKeyWithEventStore,
            symmetricKeyStore: symmetricKeyStore,
            changePINProcess: pinService.process(_:completion:),
            remoteCVVProcess: cvvService.process(_:completion:),
            processKey: keyService.process(_:completion:),
            currentDate: currentDate
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(eventIDStore, file: file, line: line)
        
        return (infra, eventIDStore, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, symmetricKeyStore, pinService, cvvService, keyService)
    }
}
