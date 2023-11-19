//
//  ComposerChangePinTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import CVVPINServices
import XCTest

final class ComposerChangePinTests: MakeComposerInfraTests {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, eventIDLoader, changePINService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        XCTAssertEqual(eventIDLoader.callCount, 0)
        XCTAssertEqual(changePINService.callCount, 0)
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
    }
    
    func test_changePIN_shouldDeliverLoadSessionIDFailureOnSessionIDLoadFailure() {
        
        let (sut, _, _, sessionIDLoader, _) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .failure(anyError()))
        }
        
        assertVoid(results, equalsTo: [.failure(.missing(.sessionID))])
    }
    
    func test_changePIN_shouldDeliverLoadSymmetricKeyFailureOnSymmetricKeyLoadFailure() {
        
        let (sut, _, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .failure(anyError()))
        }
        
        assertVoid(results, equalsTo: [.failure(.missing(.symmetricKey))])
    }
    
    func test_changePIN_shouldDeliverLoadEventIDFailureOnEventIDLoadFailure() {
        
        let (sut, eventIDLoader, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .failure(anyError()))
        }
        
        assertVoid(results, equalsTo: [.failure(.missing(.eventID))])
    }
    
    func test_changePIN_shouldDeliverErrorFailureOnPINServiceFailure() {
        
        let changePINServiceError = anyChangePINAPIError()
        let (sut, eventIDLoader, changePINService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .success(makeEventID()))
            changePINService.complete(with: .failure(changePINServiceError))
        }
        
        assertVoid(results, equalsTo: [.failure(.apiError(changePINServiceError))])
    }
    
    func test_changePIN_shouldDeliverErrorFailureOnPINServiceFailure_() {
        
        let (sut, eventIDLoader, changePINService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .success(makeEventID()))
            changePINService.complete(with: .success(()))
        }
        
        assertVoid(results, equalsTo: [.success(())])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    fileprivate typealias SUT = Composer<SessionID>
    
    fileprivate typealias ChangePINService = PINChangeServiceSpy<SessionID>
    
    private func makeSUT(
        aesEncrypt: SUT.Crypto.AESEncrypt? = nil,
        rsaEncrypt: SUT.Crypto.RSAEncrypt? = nil,
        sha256Hash: SUT.Crypto.SHA256Hash? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        eventIDLoader: EventIDLoaderSpy,
        changePINService: ChangePINService,
        sessionIDLoader: SessionIDLoaderSpy<SessionID>,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let (infra, eventIDLoader, _, _, sessionIDLoader, _, _, symmetricKeyLoader) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let (remote, _, _, changePINService) = makeCVVPRemote(SessionID.self, file: file, line: line)
        let sut = SUT(
            crypto: .test(
                aesEncrypt: aesEncrypt,
                rsaEncrypt: rsaEncrypt,
                sha256Hash: sha256Hash
            ),
            infra: infra,
            remote: remote
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, eventIDLoader, changePINService, sessionIDLoader, symmetricKeyLoader)
    }
    
    private func changePINResults(
        _ sut: SUT,
        cardID: CardID = makeCardID(),
        otp: OTP = makeOTP(),
        pin: PIN = makePIN(),
        on action: @escaping () -> Void
    ) -> [Result<Void, PINError>] {
        
        var results = [Result<Void, PINError>]()
        let exp = expectation(description: "wait for completion")
        
        let changePIN = sut.changePIN()
        changePIN(cardID, otp, pin) {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return results
    }
}

private func makeSessionID(
    _ rawValue: String = UUID().uuidString
) -> ComposerChangePinTests.SessionID {
    
    .init(rawValue: rawValue)
}
