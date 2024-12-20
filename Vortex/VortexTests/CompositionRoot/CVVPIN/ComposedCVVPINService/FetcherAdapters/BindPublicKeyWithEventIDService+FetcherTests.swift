//
//  BindPublicKeyWithEventIDService+FetcherTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
import Fetcher
@testable import Vortex
import XCTest

fileprivate typealias SUT = CVVPIN_Services.BindPublicKeyWithEventIDService

final class BindPublicKeyWithEventIDService_FetcherTests: XCTestCase {
    
    func test_fetch_shouldDeliverErrorOnLoadEventIDFailure() {
        
        let sut = makeSUT(
            loadEventIDResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.missingEventID)))
    }
    
    func test_fetch_shouldDeliverErrorOnMakeSecretJSONFailure() {
        
        let sut = makeSUT(
            makeSecretJSONResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)))
    }
    
    func test_fetch_shouldDeliverErrorOnProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(
            processResult: .failure(.invalid(statusCode: statusCode, data: invalidData))
        )
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)))
    }
    
    func test_fetch_shouldDeliverErrorOnProcessNetworkFailure() {
        
        let sut = makeSUT(
            processResult: .failure(.network)
        )
        
        expect(sut, toDeliver: .failure(.network))
    }
    
    func test_fetch_shouldDeliverErrorOnProcessRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure. Retry"
        let retryAttempts = 7
        let sut = makeSUT(
            processResult: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        )
        
        expect(sut, toDeliver: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
    }
    
    func test_fetch_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure. Retry"
        let sut = makeSUT(
            processResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_fetch_shouldDeliverVoidOnSuccess() {
        
        let sut = makeSUT()
        
        expect(sut, toDeliver: .success(()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        loadEventIDResult: SUT.EventIDResult = anySuccess(),
        makeSecretJSONResult: SUT.SecretJSONResult = anySuccess(),
        processResult: SUT.ProcessResult = .success(()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            loadEventID: { completion in
                
                completion(loadEventIDResult)
            },
            makeSecretJSON: { _, completion in
                
                completion(makeSecretJSONResult)
            },
            process: { _, completion in
                
                completion(processResult)
            }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: SUT.FetchResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(anyOTP()) { receivedResult in
            
            switch (expectedResult, receivedResult) {
            case let (
                .failure(expected),
                .failure(received)
            ):
                switch (expected, received) {
                case let (
                    .invalid(expectedStatusCode, expectedInvalidData),
                    .invalid(receivedStatusCode, receivedInvalidData)
                ):
                    XCTAssertNoDiff(expectedStatusCode, receivedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(expectedInvalidData, receivedInvalidData, file: file, line: line)
                    
                case (.network, .network):
                    break
                    
                case let (
                    .retry(expectedStatusCode, expectedErrorMessage, expectedRetryAttempts),
                    .retry(receivedStatusCode, receivedErrorMessage, receivedRetryAttempts)
                ):
                    XCTAssertNoDiff(expectedStatusCode, receivedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(expectedErrorMessage, receivedErrorMessage, file: file, line: line)
                    XCTAssertNoDiff(expectedRetryAttempts, receivedRetryAttempts, file: file, line: line)
                    
                case let (
                    .server(expectedStatusCode, expectedErrorMessage),
                    .server(receivedStatusCode, receivedErrorMessage)
                ):
                    XCTAssertNoDiff(expectedStatusCode, receivedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(expectedErrorMessage, receivedErrorMessage, file: file, line: line)
                    
                case let (
                    .serviceError(expected),
                    .serviceError(received)
                ):
                    switch (expected, received) {
                    case (.makeJSONFailure, .makeJSONFailure),
                        (.missingEventID, .missingEventID):
                        break
                        
                    default:
                        XCTFail("Expected \(expected), but got \(received)", file: file, line: line)
                    }
                    
                default:
                    XCTFail("Expected \(expected), but got \(received)", file: file, line: line)
                }
                
            case (.success(()), .success(())):
                break
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func anySuccess(
    eventIDValue: String = UUID().uuidString
) -> SUT.EventIDResult {
    
    .success(.init(eventIDValue: eventIDValue))
}

private func anySuccess(
    data: Data = anyData()
) -> SUT.SecretJSONResult {
    
    .success(data)
}

private func anyOTP(
    otpValue: String = UUID().uuidString
) -> SUT.OTP {
    
    .init(otpValue: otpValue)
}
