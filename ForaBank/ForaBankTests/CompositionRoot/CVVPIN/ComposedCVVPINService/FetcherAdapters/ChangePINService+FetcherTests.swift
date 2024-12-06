//
//  ChangePINService+FetcherTests.swift
//  VortexTests
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
        
        let (sut, _) = makeSUT(
            authenticateResult: .failure(.activationFailure)
        )
        
        expect(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_fetch_shouldDeliverErrorOnAuthenticateFailure() {
        
        let (sut, _) = makeSUT(
            authenticateResult: .failure(.authenticationFailure)
        )
        
        expect(sut, toDeliver: .failure(.authenticationFailure))
    }
    
    func test_fetch_shouldDeliverErrorOnConfirmProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _) = makeSUT(
            confirmProcessResult: .failure(.invalid(statusCode: statusCode, data: invalidData))
        )
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)))
    }
    
    func test_fetch_shouldDeliverErrorOnConfirmProcessNetworkFailure() {
        
        let (sut, _) = makeSUT(
            confirmProcessResult: .failure(.network)
        )
        
        expect(sut, toDeliver: .failure(.network))
    }
    
    func test_fetch_shouldDeliverErrorOnConfirmProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirm Failure"
        let (sut, _) = makeSUT(
            confirmProcessResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_fetch_shouldDeliverErrorOnDecryptEventIDFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.decryptionFailure), on: {
            
            spy.complete(with: .failure(anyError()))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnDecryptPhoneFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.decryptionFailure), on: {
            
            spy.complete(with: .success(UUID().uuidString))
            spy.complete(with: .failure(anyError()), at: 1)
        })
    }
    
    func test_fetch_shouldDeliverValueOnSuccess() {
        
        let eventIDValue = UUID().uuidString
        let phone = "+7..9876"
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            otpEventID: .init(eventIDValue: eventIDValue),
            phone: phone
        )), on: {
            
            spy.complete(with: .success(eventIDValue))
            spy.complete(with: .success(phone), at: 1)
        })
    }
    
    // MARK: - Helpers
    
    private typealias DecryptSpy = Spy<String, String, Error>
    
    private func makeSUT(
        authenticateResult: SUT.AuthenticateResult = anySuccess(),
        confirmProcessResult: SUT.ConfirmProcessResult = anySuccess(),
        makePINChangeJSONResult: SUT.MakePINChangeJSONResult = anySuccess(),
        changePINProcessResult: SUT.ChangePINProcessResult = .success(()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: DecryptSpy
    ) {
        let spy = DecryptSpy()
        let sut = SUT(
            authenticate: { completion in
                
                completion(authenticateResult)
            },
            publicRSAKeyDecrypt: spy.process(_:completion:),
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
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: SUT.FetchResult,
        on action: @escaping () -> Void = {},
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
                    (.authenticationFailure, .authenticationFailure),
                    (.decryptionFailure, .decryptionFailure):
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
                    .server(expectedStatusCode, expectedErrorMessage),
                    .server(receivedStatusCode, receivedErrorMessage)
                ):
                    XCTAssertNoDiff(expectedStatusCode, receivedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(expectedErrorMessage, receivedErrorMessage, file: file, line: line)
                    
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
        
        action()
        
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
