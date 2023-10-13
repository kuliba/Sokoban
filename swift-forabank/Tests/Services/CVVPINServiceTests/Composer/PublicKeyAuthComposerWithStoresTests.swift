//
//  PublicKeyAuthComposerWithStoresTests.swift
//
//
//  Created by Igor Malyarov on 10.10.2023.
//

@testable import CVVPINService
import XCTest

final class PublicKeyAuthComposerWithStoresTests: MakeComposerInfraTests {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDStore, symmetricKeyStore) = makeSUT()
        
        XCTAssertEqual(keyPairLoader.callCount, 0)
        XCTAssertEqual(sessionKeyWithEventLoader.callCount, 0)
        XCTAssertEqual(sessionIDStore.callCount, 0)
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        XCTAssertEqual(keyService.callCount, 0)
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnRSAKeyPairLoadFailure() {
        
        let loadRSAKeyPairError = anyError("RSAKeyPair Load Failure")
        let (sut, keyPairLoader, _, _, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            keyPairLoader.complete(with: .failure(loadRSAKeyPairError))
        })
        
        assert(results, equalsTo: [.failure(loadRSAKeyPairError)])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnSessionKeyWithEventLoadSuccess() {
        
        let (sut, keyPairLoader, _, sessionKeyWithEventLoader, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .success(makeSessionKeyWithEvent()))
        })
        
        assert(results, equalsTo: [.success(())])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnKeyServiceFailure() {
        
        let keyServiceError = anyError("Key Service Failure")
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .failure(keyServiceError))
        })
        
        assert(results, equalsTo: [.failure(keyServiceError)])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnKeyServiceSuccess() {
        
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        assert(results, equalsTo: [.success(())])
    }
    
    func test_authenticateWithPublicKey_shouldRequestSessionIDDeleteOnKeyServiceSuccess() {
        
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDStore, _) = makeSUT()
        XCTAssertEqual(sessionIDStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        XCTAssertEqual(sessionIDStore.messages, [.delete])
    }
    
    func test_authenticateWithPublicKey_shouldRequestSessionIDInsertionOnKeyServiceAndDeletionSuccess() {
        
        let response = makePublicKeyAuthenticationResponse()
        let currentDate = Date()
        let validUntil = currentDate + response.sessionTTL
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDStore, _) = makeSUT(
            currentDate: { currentDate }
        )
        XCTAssertEqual(sessionIDStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(response))
            sessionIDStore.completeDeletionSuccessfully()
        })
        
        XCTAssertNoDiff(sessionIDStore.messages, [
            .delete,
            .insert(response.sessionID, validUntil)
        ])
    }
    
    func test_authenticateWithPublicKey_shouldRequestsymmetricKeyDeleteOnKeyServiceSuccess() {
        
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, symmetricKeyStore) = makeSUT()
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        XCTAssertEqual(symmetricKeyStore.messages, [.delete])
    }
    
    func test_authenticateWithPublicKey_shouldRequestSymmetricKeyInsertionOnKeyServiceAndDeletionSuccess() {
        
        let response = makePublicKeyAuthenticationResponse()
        let symmetricKey = makeSymmetricKey()
        let currentDate = Date()
        let validUntil = currentDate + response.sessionTTL
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, symmetricKeyStore) = makeSUT(
            makeSymmetricKey: { _,_ in symmetricKey },
            currentDate: { currentDate }
        )
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(response))
            symmetricKeyStore.completeDeletionSuccessfully()
        })
        
        XCTAssertNoDiff(symmetricKeyStore.messages, [
            .delete,
            .insert(symmetricKey, validUntil)
        ])
    }
    
    func test_authenticateWithPublicKey_should_______() {
        
        let response = makePublicKeyAuthenticationResponse()
        let symmetricKey = makeSymmetricKey()
        let currentDate = Date()
        let validUntil = currentDate + response.sessionTTL
        let (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, _, symmetricKeyStore) = makeSUT(
            makeSymmetricKey: { _,_ in symmetricKey },
            currentDate: { currentDate }
        )
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionKeyWithEventLoader.complete(with: .failure(anyError()))
            keyService.complete(with: .success(response))
            symmetricKeyStore.completeDeletionSuccessfully()
        })
        
        XCTAssertNoDiff(symmetricKeyStore.messages, [
            .delete,
            .insert(symmetricKey, validUntil)
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    private typealias Composer = CVVPINComposer<CardID, CVV, ECDHPublicKey, ECDHPrivateKey, EventID, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, PublicKeyAuthenticationResponse.SessionID, SymmetricKey>
    private typealias SUT = Composer.PublicKeyAuth
    private typealias KeyService = RemoteServiceSpyOf<PublicKeyAuthenticationResponse>
    
    private func makeSUT(
        makeSymmetricKey: Composer.Crypto.MakeSymmetricKey? = nil,
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        keyPairLoader: LoaderSpyOf<RSAKeyPair>,
        keyService: KeyService,
        sessionKeyWithEventLoader: LoaderSpyOf<SessionKeyWithEvent>,
        sessionIDStore: StoreSpy<SessionID>,
        symmetricKeyStore: StoreSpy<SymmetricKey>
    ) {
        let (infra, _, keyPairLoader, sessionIDStore, sessionKeyWithEventLoader, _, _, keyService, symmetricKeyStore) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let composer = Composer(
            crypto: .test(
                makeSymmetricKey: makeSymmetricKey
            ),
            infra: infra
        )
        
        let sut = composer.composePublicKeyAuth(currentDate: currentDate)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, keyPairLoader, keyService, sessionKeyWithEventLoader, sessionIDStore, symmetricKeyStore)
    }
    
    private func authResults(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) -> [Result<Void, Error>] {
        
        var receivedResults = [Result<Void, Error>]()
        let exp = expectation(description: "wait for completion")
        
        sut.authenticateWithPublicKey {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResults
    }
}
