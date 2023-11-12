//
//  Services+makeBindPublicKeyServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

@available(iOS 16.0.0, *)
final class Services_makeBindPublicKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(handleFailureSpy.callCount, 0)
        XCTAssertEqual(processSpy.callCount, 0)
    }
    
    func test_handleFailure_shouldReceiveFailureOnLoadSessionIDFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, _) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: .failure(anyError()))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnMakeSecretJSONFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, _) = makeSUT(
            makeSecretJSONResult: .failure(anyError())
        )
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessCreateRequestFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.createRequest(anyError())))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessPerformRequestFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.performRequest(anyError())))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseInvalidFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.invalid(statusCode: 500, data: anyData()))))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseNetworkFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.network)))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseRetryFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.retry(statusCode: 500, errorMessage: "Retry Failure", retryAttempts: 2))))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldReceiveFailureOnProcessMapResponseServerFailure() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.server(statusCode: 500, errorMessage: "Server Failure"))))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 1)
    }
    
    func test_handleFailure_shouldNotReceiveFailureOnSuccess() {
        
        let (sut, handleFailureSpy, sessionIDLoader, processSpy) = makeSUT()
        
        expectSuccess(sut, on: {
            
            sessionIDLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .success(()))
        })
        XCTAssertEqual(handleFailureSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Services.BindPublicKeyService
    private typealias SessionIDLoader = LoaderSpy<SessionID>
    private typealias ProcessSpy = Spy<BindPublicKeyWithEventIDService.ProcessPayload, Void, Services.BindPublicKeyProcessError>
    
    private func makeSUT(
        makeSecretJSONResult: Result<Data, Error> = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        handleFailureSpy: HandleFailureSpy,
        sessionIDLoader: SessionIDLoader,
        processSpy: ProcessSpy
    ) {
        let sessionIDLoader = SessionIDLoader()
        let processSpy = ProcessSpy()
        let handleFailureSpy = HandleFailureSpy()
        let sut = Services.makeBindPublicKeyService(
            sessionIDLoader: sessionIDLoader,
            bindPublicKeyProcess: processSpy.process,
            makeSecretJSON: { _, completion in
                
                completion(makeSecretJSONResult)
            },
            onBindKeyFailure: handleFailureSpy.handleFailure(_:)
        )
        
        trackForMemoryLeaks(sessionIDLoader, file: file, line: line)
        trackForMemoryLeaks(handleFailureSpy, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        
        return (sut, handleFailureSpy, sessionIDLoader, processSpy)
    }
    
    private func expectSuccess(
        _ sut: any SUT,
        with otp: BindPublicKeyWithEventIDService.OTP? = nil,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(otp ?? anyOTP()) { receivedResult in
            
            switch receivedResult {
            case .failure:
                XCTFail("Expected success, but got failure.", file: file, line: line)
                
            case .success:
                break
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectFailure(
        _ sut: any SUT,
        with otp: BindPublicKeyWithEventIDService.OTP? = nil,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(otp ?? anyOTP()) { receivedResult in
            
            switch receivedResult {
            case .failure:
                break
                
            case .success:
                XCTFail("Expected failure, but got success.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private final class HandleFailureSpy {
        
        typealias Failure = BindPublicKeyWithEventIDService.Failure
        
        private(set) var failures = [Failure]()
        
        var callCount: Int { failures.count }
        
        func handleFailure(_ failure: Failure) {
            
            failures.append(failure)
        }
    }
}

private func anySuccess(
    _ data: Data = anyData()
) -> Result<Data, Error> {
    
    .success(data)
}

private func anySuccess(
    _ value: String = UUID().uuidString
) -> Result<SessionID, Error> {
    
    .success(.init(sessionIDValue: value))
}

private func anyOTP(
    _ otpValue: String = UUID().uuidString
) -> BindPublicKeyWithEventIDService.OTP {
    
    .init(otpValue: otpValue)
}
