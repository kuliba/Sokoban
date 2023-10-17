//
//  ComposerPublicKeyAuthTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import CVVPINService
import XCTest

final class ComposerPublicKeyAuthTests: MakeComposerInfraTests {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDCache, sessionIDLoader, symmetricKeyCache, symmetricKeyLoader) = makeSUT()
        
        XCTAssertEqual(keyPairLoader.callCount, 0)
        XCTAssertEqual(sessionKeyWithEventLoader.callCount, 0)
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
        XCTAssertEqual(keyService.callCount, 0)
        XCTAssertEqual(sessionIDCache.callCount, 0)
        XCTAssertEqual(symmetricKeyCache.callCount, 0)
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnLoadRSAPairFailure() {
        
        let loadRSAKeyPairError = anyError("Load RSAKeyPair Failure")
        let (sut, keyPairLoader, _, _, _, _, _, _) = makeSUT()
        
        let authResults = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .failure(loadRSAKeyPairError))
        })
        
        assertVoid(authResults, equalsTo: [.failure(.missing(.rsaKeyPair))])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnServiceFailure() {
        
        let loadSessionKeyWithEventError = anyError("Load SessionKeyWithEvent Failure")
        let processError = anyKeyServiceAPIError()
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, _, _, _) = makeSUT()
        
        let authResults = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(loadSessionKeyWithEventError))
            keyService.complete(with: .failure(processError))
        })
        
        assertVoid(authResults, equalsTo: [.failure(.apiError(processError))])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnSuccessfulSessionKeyWithEventLoad() {
        
        let (sut, keyPairLoader, _, sessionKeyWithEventLoader, _, _, _, _) = makeSUT()
        
        let authResults = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .success(makeSessionKeyWithEvent()))
        })
        
        assertVoid(authResults, equalsTo: [.success(())])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnServiceSuccess() {
        
        let publicKeyAuthenticationResponse = makePublicKeyAuthenticationResponse()
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, _, _, _) = makeSUT()
        
        let authResults = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(publicKeyAuthenticationResponse))
        })
        
        assertVoid(authResults, equalsTo: [.success(())])
    }
    
    func test_authenticateWithPublicKey_shouldCacheSessionIDOnKeyServiceSuccess() {
        
        let response = makePublicKeyAuthenticationResponse(sessionIDValue: "deadbeef")
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDCache, _, _, _) = makeSUT()
        XCTAssertEqual(sessionIDCache.messages.map(\.model.0), [])
        
        _ = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(response))
        })
        
        XCTAssertEqual(sessionIDCache.messages.map(\.model.0), [.init(value: "deadbeef")])
    }
    
    func test_authenticateWithPublicKey_shouldNotCacheSessionIDOnSessionKeyWithEventLoaderSuccess() {
        
        let (sut, keyPairLoader, _, sessionKeyWithEventLoader, sessionIDCache, _, _, _) = makeSUT()
        XCTAssertEqual(sessionIDCache.messages.map(\.model.0), [])
        
        _ = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .success(makeSessionKeyWithEvent()))
        })
        
        XCTAssertEqual(sessionIDCache.messages.map(\.model.0), [])
    }
    
    func test_authenticateWithPublicKey_shouldSaveSymmetricKeyOnMakeSymmetricKeySuccess() {
        
        let symmetricKey = SymmetricKey("deadbeef")
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, _, symmetricKeyCache, _) = makeSUT(
            makeSymmetricKey: { _,_ in symmetricKey }
        )
        XCTAssertEqual(symmetricKeyCache.messages.map(\.model.0), [])
        
        _ = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        XCTAssertEqual(symmetricKeyCache.messages.map(\.model.0), [symmetricKey])
    }
    
    func test_authenticateWithPublicKey_shouldNotSaveSymmetricKeyOnMakeSymmetricKeyFailure() {
        
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, _, symmetricKeyCache, _) = makeSUT(
            makeSymmetricKey: { _,_ in throw anyError() }
        )
        XCTAssertEqual(symmetricKeyCache.messages.map(\.model.0), [])
        
        _ = authenticateWithPublicKey(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        XCTAssertEqual(symmetricKeyCache.messages.map(\.model.0), [])
    }
    
    // MARK: - Helpers
    
    private typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    private typealias SUT = Composer<SessionID>
    
    private func makeSUT(
        publicTransportDecrypt: ((Data) throws -> Data)? = nil,
        makeSymmetricKey: ((Data, ECDHPrivateKey) throws -> SymmetricKey)? = nil,
        makeECDHKeyPair: (() throws -> (publicKey: ECDHPublicKey, privateKey: ECDHPrivateKey))? = nil,
        sign: ((Data, RSAPrivateKey) throws -> Data)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        keyPairLoader: RSAKeyPairLoaderSpy,
        keyService: KeyServiceSpy,
        sessionKeyWithEventLoader: SessionKeyWithEventLoaderSpy,
        sessionIDCache: SessionIDCache<SessionID>,
        sessionIDLoader: SessionIDLoaderSpy<SessionID>,
        symmetricKeyCache: SymmetricKeyCache,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let crypto = SUT.Crypto.test(
            publicTransportDecrypt: publicTransportDecrypt,
            makeSymmetricKey: makeSymmetricKey,
            makeECDHKeyPair: makeECDHKeyPair,
            sign: sign
        )
        let (infra, _, _, keyPairLoader, keyService, _, sessionIDCache, sessionIDLoader, sessionKeyWithEventLoader, symmetricKeyCache, symmetricKeyLoader) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let sut = SUT(crypto: crypto, infra: infra)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDCache, sessionIDLoader, symmetricKeyCache, symmetricKeyLoader)
    }
    
    private func authenticateWithPublicKey(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) -> [Result<Void, KeyExchangeError<KeyServiceAPIError>>] {
        
        var authResults = [Result<Void, KeyExchangeError<KeyServiceAPIError>>]()
        let exp = expectation(description: "wait for completion")
        
        let authenticateWithPublicKey = sut.authenticateWithPublicKey()
        authenticateWithPublicKey {
            
            authResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return authResults
    }
}
