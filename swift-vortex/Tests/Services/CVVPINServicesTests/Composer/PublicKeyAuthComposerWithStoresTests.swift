//
//  PublicKeyAuthComposerWithStoresTests.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import CVVPINServices
import XCTest

final class PublicKeyAuthComposerWithStoresTests: MakeComposerInfraTests {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, eventIDStore, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, symmetricKeyStore, changePINService, showCVVService, keyService) = makeSUT()
        
        XCTAssertEqual(eventIDStore.callCount, 0)
        XCTAssertEqual(rsaKeyPairStore.callCount, 0)
        XCTAssertEqual(sessionIDStore.callCount, 0)
        XCTAssertEqual(sessionKeyWithEventStore.callCount, 0)
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        XCTAssertEqual(changePINService.callCount, 0)
        XCTAssertEqual(showCVVService.callCount, 0)
        XCTAssertEqual(keyService.callCount, 0)
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnRSAKeyPairLoadFailure() {
        
        let loadRSAKeyPairError = anyError("RSAKeyPair Load Failure")
        let (sut, _, rsaKeyPairStore, _, _, _, _, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: loadRSAKeyPairError)
        })
        
        assertVoid(results, equalsTo: [.failure(.missing(.rsaKeyPair))])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnInvalidRSAKeyPair() {
        
        let invalidRSAKeyPair = (makeRSAKeyPair(), Date())
        let (sut, _, rsaKeyPairStore, _, _, _, _, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: invalidRSAKeyPair)
        })
        
        XCTAssertEqual(results.count, 1)
        switch results.first {
        case .failure:
            break
        default:
            XCTFail("Expected failure.")
        }
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnValidSessionKeyWithEventLoadSuccess() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let validSessionKeyWithEvent = (makeSessionKeyWithEvent(), Date().addingTimeInterval(5))
        let (sut, _, rsaKeyPairStore, _, sessionKeyWithEventStore, _, _, _, _) = makeSUT()
        
        let results = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: validSessionKeyWithEvent)
        })
        
        assertVoid(results, equalsTo: [.success(())])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnKeyServiceFailure() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let keyServiceError = anyKeyServiceAPIError()
        let (sut, _, rsaKeyPairStore, _, sessionKeyWithEventStore, _, _, _, keyService) = makeSUT()
        
        let results = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
            keyService.complete(with: .failure(keyServiceError))
        })
        
        assertVoid(results, equalsTo: [.failure(.apiError(keyServiceError))])
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnKeyServiceSuccess() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let (sut, _, rsaKeyPairStore, _, sessionKeyWithEventStore, _, _, _, keyService) = makeSUT()
        
        let results = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        assertVoid(results, equalsTo: [.success(())])
    }
    
    func test_authenticateWithPublicKey_shouldRequestSessionIDDeleteOnKeyServiceSuccess() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let (sut, _, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, _, _, _, keyService) = makeSUT()
        XCTAssertEqual(sessionIDStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        XCTAssertEqual(sessionIDStore.messages, [.delete])
    }
    
    func test_authenticateWithPublicKey_shouldRequestSessionIDInsertionOnKeyServiceAndDeletionSuccess() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let response = makePublicKeyAuthenticationResponse()
        let currentDate = Date()
        let validUntil = currentDate + response.sessionTTL
        let (sut, _, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, _, _, _, keyService) = makeSUT(
            currentDate: { currentDate }
        )
        XCTAssertEqual(sessionIDStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
            keyService.complete(with: .success(response))
            sessionIDStore.completeDeletionSuccessfully()
        })
        
        XCTAssertNoDiff(sessionIDStore.messages, [
            .delete,
            .insert(response.sessionID, validUntil)
        ])
    }
    
    func test_authenticateWithPublicKey_shouldRequestsymmetricKeyDeleteOnKeyServiceSuccess() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let (sut, _, rsaKeyPairStore, _, sessionKeyWithEventStore, symmetricKeyStore, _, _, keyService) = makeSUT()
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
            keyService.complete(with: .success(makePublicKeyAuthenticationResponse()))
        })
        
        XCTAssertEqual(symmetricKeyStore.messages, [.delete])
    }
    
    func test_authenticateWithPublicKey_shouldRequestSymmetricKeyInsertionOnKeyServiceAndDeletionSuccess() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let response = makePublicKeyAuthenticationResponse()
        let symmetricKey = makeSymmetricKey()
        let currentDate = Date()
        let validUntil = currentDate + response.sessionTTL
        let (sut, _, rsaKeyPairStore, _, sessionKeyWithEventStore, symmetricKeyStore, _, _, keyService) = makeSUT(
            makeSymmetricKey: { _,_ in symmetricKey },
            currentDate: { currentDate }
        )
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
            keyService.complete(with: .success(response))
            symmetricKeyStore.completeDeletionSuccessfully()
        })
        
        XCTAssertNoDiff(symmetricKeyStore.messages, [
            .delete,
            .insert(symmetricKey, validUntil)
        ])
    }
    
    func test_authenticateWithPublicKey_should_______() {
        
        let validRSAKeyPair = (makeRSAKeyPair(), Date().addingTimeInterval(5))
        let response = makePublicKeyAuthenticationResponse()
        let symmetricKey = makeSymmetricKey()
        let currentDate = Date()
        let validUntil = currentDate + response.sessionTTL
        let (sut, _, rsaKeyPairStore, _, sessionKeyWithEventStore, symmetricKeyStore, _, _, keyService) = makeSUT(
            makeSymmetricKey: { _,_ in symmetricKey },
            currentDate: { currentDate }
        )
        XCTAssertEqual(symmetricKeyStore.callCount, 0)
        
        _ = authResults(sut, on: {
            
            rsaKeyPairStore.completeRetrieval(with: validRSAKeyPair)
            sessionKeyWithEventStore.completeRetrieval(with: anyError())
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
    private typealias SUT = Composer<SessionID>.PublicKeyAuth
    private typealias Crypto = Composer<SessionID>.Crypto
    
    private typealias PINServiceSpy = PINChangeServiceSpy<SessionID>
    
    private func makeSUT(
        makeSymmetricKey: Crypto.MakeSymmetricKey? = nil,
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        eventIDStore: StoreSpy<EventID>,
        rsaKeyPairStore: StoreSpy<RSAKeyPair>,
        sessionIDStore: StoreSpy<SessionID>,
        sessionKeyWithEventStore: StoreSpy<SessionKeyWithEvent>,
        symmetricKeyStore: StoreSpy<SymmetricKey>,
        changePINService: PINServiceSpy,
        showCVVService: ShowCVVServiceSpy<SessionID>,
        keyService: KeyServiceSpy
    ) {
        let (infra, eventIDStore, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, symmetricKeyStore) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let (remote, changePINService, showCVVService, keyService) = makeCVVPINRemote(SessionID.self, file: file, line: line)
        let composer = Composer(
            crypto: .test(
                makeSymmetricKey: makeSymmetricKey
            ),
            infra: infra,
            remote: remote
        )
        
        let sut = composer.composePublicKeyAuth(currentDate: currentDate)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, eventIDStore, rsaKeyPairStore, sessionIDStore, sessionKeyWithEventStore, symmetricKeyStore, changePINService, showCVVService, keyService)
    }
    
    private func authResults(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) -> [KeyExchangeResult] {
        
        var receivedResults = [KeyExchangeResult]()
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
