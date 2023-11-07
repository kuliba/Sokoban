//
//  ChangePINService+FetcherTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
import Fetcher
@testable import ForaBank
import XCTest

fileprivate typealias SUT = ChangePINService

final class ChangePINService_FetcherTests: XCTestCase {
    
    func test_fetch_shouldDeliverErrorOnActivationFailure() {
        
        let sut = makeSUT(
            authenticateResult: .failure(.activationFailure)
        )
        
        expect(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_fetch_shouldDeliverErrorOnAuthenticateFailure() {
        
        let sut = makeSUT(
            authenticateResult: .failure(.authenticationFailure)
        )
        
        expect(sut, toDeliver: .failure(.authenticationFailure))
    }
    
    func test_fetch_shouldDeliverErrorOnConfirmProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(
            confirmProcessResult: .failure(.invalid(statusCode: statusCode, data: invalidData))
        )
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)))
    }
    
    func test_fetch_shouldDeliverErrorOnConfirmProcessNetworkFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(
            confirmProcessResult: .failure(.network)
        )
        
        expect(sut, toDeliver: .failure(.network))
    }
    
    func test_fetch_shouldDeliverErrorOnConfirmProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirm Failure"
        let sut = makeSUT(
            confirmProcessResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_fetch_shouldDeliverErrorOnDecryptFailure() {
        
        let sut = makeSUT(
            publicRSAKeyDecryptResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.decryptionFailure)))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        authenticateResult: SUT.AuthenticateResult = anySuccess(),
        confirmProcessResult: SUT.ConfirmProcessResult = anySuccess(),
        publicRSAKeyDecryptResult: SUT.PublicRSAKeyDecryptResult = anySuccess(),
        makePINChangeJSONResult: SUT.MakePINChangeJSONResult = anySuccess(),
        changePINProcessResult: SUT.ChangePINProcessResult = .success(()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            authenticate: { completion in
                
                completion(authenticateResult)
            },
            publicRSAKeyDecrypt: { _, completion in
                
                completion(publicRSAKeyDecryptResult)
            },
            confirmProcess: { _, completion in
                
                completion(confirmProcessResult)
            },
            makePINChangeJSON: { _,_,_, completion in
                
                completion(makePINChangeJSONResult)
            },
            changePINProcess: { _, completion in
                
                completion(changePINProcessResult)
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
        
        sut.fetch { receivedResult in
            
            switch (expectedResult, receivedResult) {
            case let (
                .failure(expected),
                .failure(received)
            ):
                switch (expected, received) {
                case (.activationFailure, .activationFailure),
                    (.authenticationFailure, .authenticationFailure):
                    break
                    
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
                    case (.checkSessionFailure, .checkSessionFailure),
                        (.decryptionFailure, .decryptionFailure),
                        (.makeJSONFailure, .makeJSONFailure):
                        break
                        
                    default:
                        XCTFail("Expected \(expected), but got \(received)", file: file, line: line)
                    }
                    
                default:
                    XCTFail("Expected \(expected), but got \(received)", file: file, line: line)
                }
                
            case let (.success(expected), .success(received)):
                XCTAssertNoDiff(expected.equatable, received.equatable)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension ChangePINService.ConfirmResponse {
    
    var equatable: EquatableConfirmResponse {
        
        .init(
            otpEventIDValue: otpEventID.eventIDValue,
            phone: phone
        )
    }
    
    struct EquatableConfirmResponse: Equatable {
        
        let otpEventIDValue: String
        let phone: String
    }
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString
) -> SUT.AuthenticateResult {
    
    .success(.init(sessionIDValue: sessionIDValue))
}

private func anySuccess(
    string: String = UUID().uuidString
) -> SUT.PublicRSAKeyDecryptResult {
    
    .success(string)
}

private func anySuccess(
    eventIDValue: String = UUID().uuidString,
    phone: String = UUID().uuidString
) -> SUT.ConfirmProcessResult {
    
    .success(.init(eventID: eventIDValue, phone: phone))
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString,
    data: Data = anyData()
) -> SUT.MakePINChangeJSONResult {
    
    .success((.init(sessionIDValue: sessionIDValue), data))
}
