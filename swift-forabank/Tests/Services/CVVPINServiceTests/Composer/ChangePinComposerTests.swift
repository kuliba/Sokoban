//
//  ChangePinComposerTests.swift
//  
//
//  Created by Igor Malyarov on 08.10.2023.
//

@testable import CVVPINService
import XCTest

final class ChangePinComposerTests: MakeComposerInfraTests {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, eventIDLoader, keyPairLoader, pinService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        XCTAssertEqual(eventIDLoader.callCount, 0)
        XCTAssertEqual(keyPairLoader.callCount, 0)
        XCTAssertEqual(pinService.callCount, 0)
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
    }
    
    func test_changePIN_shouldDeliverLoadSessionIDFailureOnSessionIDLoadFailure() {
        
        let (sut, _, _, _, sessionIDLoader, _) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .failure(anyError()))
        }
        
        assert(results, equalsTo: .missing(.sessionID))
    }
    
    func test_changePIN_shouldDeliverLoadSymmetricKeyFailureOnSymmetricKeyLoadFailure() {
        
        let (sut, _, _, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .failure(anyError()))
        }
        
        assert(results, equalsTo: .missing(.symmetricKey))
    }
    
    func test_changePIN_shouldDeliverLoadEventIDFailureOnEventIDLoadFailure() {
        
        let (sut, eventIDLoader, _, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .failure(anyError()))
        }
        
        assert(results, equalsTo: .missing(.eventID))
    }
    
    func test_changePIN_shouldDeliverLoadRSAPrivateKeyFailureOnRSAPrivateKeyLoadFailure() {
        
        let (sut, eventIDLoader, keyPairLoader, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .success(makeEventID()))
            keyPairLoader.complete(with: .failure(anyError()))
        }
        
        assert(results, equalsTo: .missing(.rsaPrivateKey))
    }
    
    func test_changePIN_shouldDeliverErrorFailureOnPINServiceFailure() {
        
        let pinServiceError = anyChangePINAPIError()
        let (sut, eventIDLoader, keyPairLoader, pinService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .success(makeEventID()))
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            pinService.complete(with: pinServiceError)
        }
        
        assert(results, equalsTo: .apiError(pinServiceError))
    }
    
    func test_changePIN_shouldDeliverErrorFailureOnPINServiceFailure_() {
        
        let (sut, eventIDLoader, keyPairLoader, pinService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .success(makeEventID()))
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            pinService.complete(with: nil)
        }
        
        assert(results, equalsTo: .none)
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SUT = Composer<SessionID>.PINChanger
    private typealias Crypto = Composer<SessionID>.Crypto
    private typealias PINService = PINChangeServiceSpy<SessionID>
    
    private func makeSUT(
        aesEncrypt: Crypto.AESEncrypt? = nil,
        rsaEncrypt: Crypto.RSAEncrypt? = nil,
        sha256Hash: Crypto.SHA256Hash? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        eventIDLoader: EventIDLoaderSpy,
        keyPairLoader: RSAKeyPairLoaderSpy,
        pinService: PINService,
        sessionIDLoader: SessionIDLoaderSpy<SessionID>,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let (infra, _, eventIDLoader, keyPairLoader, _, pinService, _, sessionIDLoader, _, _, symmetricKeyLoader) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let composer = Composer<SessionID>(
            crypto: .test(
                aesEncrypt: aesEncrypt,
                rsaEncrypt: rsaEncrypt,
                sha256Hash: sha256Hash
            ),
            infra: infra
        )
        let sut = composer.composePINChanger()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, eventIDLoader, keyPairLoader, pinService, sessionIDLoader, symmetricKeyLoader)
    }
    
    private func changePINResults(
        _ sut: SUT,
        cardID: CardID = makeCardID(),
        otp: OTP = makeOTP(),
        pin: PIN = makePIN(),
        on action: @escaping () -> Void
    ) -> [PINError?] {
        
        var results = [PINError?]()
        let exp = expectation(description: "wait for completion")
        
        sut.changePIN(cardID: cardID, otp: otp, pin: pin) {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return results
    }
    
    private func assert(
        _ receivedResults: [PINError?],
        equalsTo expectedResult: PINError?,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            receivedResults.count,
            1,
            "Received \(receivedResults.count) values, but expected one.",
            file: file, line: line
        )
        
        let (received, expected) = (try! XCTUnwrap(receivedResults.first), expectedResult)
        
        switch (received, expected) {
        case (.none, .none):
            break
            
        case let (
            .some(received as NSError),
            .some(expected as NSError)
        ):
            XCTAssertEqual(received, expected, file: file, line: line)
            
        default:
            XCTFail(
                "Received \(String(describing: received)), but expected \(String(describing: expected)).",
                file: file, line: line
            )
        }
    }
}
