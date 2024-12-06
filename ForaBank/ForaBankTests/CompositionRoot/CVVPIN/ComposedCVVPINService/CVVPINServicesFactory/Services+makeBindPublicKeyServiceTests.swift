//
//  Services+makeBindPublicKeyServiceTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import ForaCrypto
import XCTest

@available(iOS 16.0.0, *)
final class Services_makeBindPublicKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(sessionKeyLoader.callCount, 0)
        XCTAssertEqual(processSpy.callCount, 0)
    }
    
    func test_handleFailure_shouldReceiveFailureOnLoadSessionIDFailure() {
        
        let (sut, sessionIDLoader, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.missingEventID)), on: {
            
            sessionIDLoader.completeLoad(with: .failure(anyError()))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnLoadSessionKeyFailure() {
        
        let (sut, sessionIDLoader, sessionKeyLoader, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: .failure(anyError()))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnMakeSecretJSONFailure() {
        
        let (sut, sessionIDLoader, sessionKeyLoader, _) = makeSUT(
            makeSecretJSONResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessCreateRequestFailure() {
        
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessPerformRequestFailure() {
        
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .failure(.performRequest(anyError())))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .failure(.mapResponse(.invalid(statusCode: statusCode, data: invalidData))))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseNetworkFailure() {
        
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .failure(.mapResponse(.network)))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Retry failure"
        let retryAttempts = 2
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .failure(.mapResponse(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))))
        })
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Server failure"
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .failure(.mapResponse(.server(statusCode: statusCode, errorMessage: errorMessage))))
        })
    }
    
    func test_handleFailure_shouldNotReceiveFailureOnSuccess() throws {
        
        let keyPair = try anyRSAKeyPair()
        let (sut, sessionIDLoader, sessionKeyLoader, processSpy) = makeSUT(
            makeSecretJSONResult: .success((anyData(), keyPair))
        )
        
        expect(sut, toDeliver: .success(keyPair), on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            sessionKeyLoader.completeLoad(with: anySuccess())
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            processSpy.complete(with: .success(()))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Services.BindPublicKeyService
    private typealias SessionIDLoader = LoaderSpy<SessionID>
    private typealias SessionKeyLoader = LoaderSpy<SessionKey>
    private typealias ProcessSpy = Spy<BindPublicKeyWithEventIDService.ProcessPayload, Void, Services.ProcessBindPublicKeyError>
    
    private func makeSUT(
        makeSecretJSONResult: Result<(Data, RSADomain.KeyPair), Error> = anySuccess(),
        ephemeralLifespan: TimeInterval = 15,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        sessionIDLoader: SessionIDLoader,
        sessionKeyLoader: SessionKeyLoader,
        processSpy: ProcessSpy
    ) {
        let sessionIDLoader = SessionIDLoader()
        let sessionKeyLoader = SessionKeyLoader()
        let processSpy = ProcessSpy()
        let sut = Services.makeBindPublicKeyService(
            loadSessionID: sessionIDLoader.load(completion:),
            loadSessionKey: sessionKeyLoader.load(completion:),
            processBindPublicKey: processSpy.process,
            makeSecretJSON: { _,_ in
                
                try makeSecretJSONResult.get()
            },
            cacheLog: { _,_,_,_ in },
            ephemeralLifespan: ephemeralLifespan
        )
        
        trackForMemoryLeaks(sessionIDLoader, file: file, line: line)
        trackForMemoryLeaks(sessionKeyLoader, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        
        return (sut, sessionIDLoader, sessionKeyLoader, processSpy)
    }
    
    private func expect(
        _ sut: any SUT,
        with otp: BindPublicKeyWithEventIDService.OTP? = nil,
        toDeliver expectedResult: Result<RSADomain.KeyPair, BindPublicKeyWithEventIDService.Error>,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(otp ?? anyOTP()) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(.invalid(statusCode: receivedStatusCode, data: receivedInvalidData)),
                .failure(.invalid(statusCode: expectedStatusCode, data: expectedInvalidData))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                
            case (.failure(.network), .failure(.network)):
                break
                
            case let (
                .failure(.retry(statusCode: receivedStatusCode, errorMessage: receivedErrorMessage, retryAttempts: receivedRetryAttempts)),
                .failure(.retry(statusCode: expectedStatusCode, errorMessage: expectedErrorMessage, retryAttempts: expectedRetryAttempts))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                XCTAssertNoDiff(receivedRetryAttempts, expectedRetryAttempts, file: file, line: line)
                
            case let (
                .failure(.server(statusCode: receivedStatusCode, errorMessage: receivedErrorMessage)),
                .failure(.server(statusCode: expectedStatusCode, errorMessage: expectedErrorMessage))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                
            case (
                .failure(.serviceError(.makeJSONFailure)),
                .failure(.serviceError(.makeJSONFailure))
            ):
                break
                
            case (
                .failure(.serviceError(.missingEventID)),
                .failure(.serviceError(.missingEventID))
            ):
                break
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received.privateKey.key, expected.privateKey.key)
                XCTAssertNoDiff(received.publicKey.key, expected.publicKey.key)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func anySuccess(
    _ data: Data = anyData()
) -> Result<(Data, RSADomain.KeyPair), Error> {
    
    .init {
        
        let keyPair = try anyRSAKeyPair()
        
        return (data, keyPair)
    }
}

private func anySuccess(
    _ value: String = UUID().uuidString
) -> Result<SessionID, Error> {
    
    .success(.init(sessionIDValue: value))
}

private func anySuccess(
    _ sessionKeyValue: Data = anyData()
) -> Result<SessionKey, Error> {
    
    .success(.init(sessionKeyValue: sessionKeyValue))
}

private func anyOTP(
    _ otpValue: String = UUID().uuidString
) -> BindPublicKeyWithEventIDService.OTP {
    
    .init(otpValue: otpValue)
}
