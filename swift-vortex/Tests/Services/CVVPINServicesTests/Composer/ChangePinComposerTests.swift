//
//  ChangePinComposerTests.swift
//  
//
//  Created by Igor Malyarov on 08.10.2023.
//

@testable import CVVPINServices
import XCTest

final class ChangePinComposerTests: MakeComposerInfraTests {
    
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
        
        assert(results, equalsTo: .failure(.missing(.sessionID)))
    }
    
    func test_changePIN_shouldDeliverLoadSymmetricKeyFailureOnSymmetricKeyLoadFailure() {
        
        let (sut, _, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .failure(anyError()))
        }
        
        assert(results, equalsTo: .failure(.missing(.symmetricKey)))
    }
    
    func test_changePIN_shouldDeliverLoadEventIDFailureOnEventIDLoadFailure() {
        
        let (sut, eventIDLoader, _, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .failure(anyError()))
        }
        
        assert(results, equalsTo: .failure(.missing(.eventID)))
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
        
        assert(results, equalsTo: .failure(.apiError(changePINServiceError)))
    }
    
    func test_changePIN_shouldDeliverErrorFailureOnPINServiceFailure_() {
        
        let (sut, eventIDLoader, changePINService, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let results = changePINResults(sut) {
            
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            eventIDLoader.complete(with: .success(makeEventID()))
            changePINService.complete(with: .success(()))
        }
        
        assert(results, equalsTo: .success(()))
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
        changePINService: PINService,
        sessionIDLoader: SessionIDLoaderSpy<SessionID>,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let (infra, eventIDLoader, _, _, sessionIDLoader, _, _, symmetricKeyLoader) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let (remote, _, _, changePINService) = makeCVVPRemote(SessionID.self, file: file, line: line)
        let composer = Composer<SessionID>(
            crypto: .test(
                aesEncrypt: aesEncrypt,
                rsaEncrypt: rsaEncrypt,
                sha256Hash: sha256Hash
            ),
            infra: infra,
            remote: remote
        )
        let sut = composer.composePINChanger()
        
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
        
        sut.changePIN(cardID: cardID, otp: otp, pin: pin) {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return results
    }
    
    private func assert(
        _ receivedResults: [Result<Void, PINError>],
        equalsTo expectedResult: Result<Void, PINError>,
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
        case (.success, .success):
            break
            
        case let (
            .failure(received as NSError),
            .failure(expected as NSError)
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
