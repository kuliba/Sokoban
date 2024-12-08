//
//  AuthenticateWithPublicKeyService+FetcherTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
import Fetcher
@testable import Vortex
import XCTest

fileprivate typealias SUT = AuthenticateWithPublicKeyService

final class AuthenticateWithPublicKeyService_FetcherTests: XCTestCase {
    
    func test_fetch_shouldDeliverFailureOnPrepareExchangeKeyFailure () {
        
        let sut = makeSUT(
            prepareKeyExchangeResult: .failure(anyNSError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.prepareKeyExchangeFailure)))
    }
    
    func test_fetch_shouldDeliverFailureOnProcessInvalidFailure () {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(
            processResult: .failure(.invalid(statusCode: statusCode, data: invalidData))
        )
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)))
    }
    
    func test_fetch_shouldDeliverFailureOnProcessNetworkFailure () {
        
        let sut = makeSUT(
            processResult: .failure(.network)
        )
        
        expect(sut, toDeliver: .failure(.network))
    }
    
    func test_fetch_shouldDeliverFailureOnProcessServerFailure () {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let sut = makeSUT(
            processResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_fetch_shouldDeliverFailureOnMakeSessionKeyFailure () {
        
        let sut = makeSUT(
            makeSessionKeyResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.makeSessionKeyFailure)))
    }
    
    func test_fetch_shouldDeliverValueOnSuccess () {
        
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let sessionTTL = 39
        let sut = makeSUT(
            processResult: .success(.init(
                sessionID: sessionIDValue,
                publicServerSessionKey: UUID().uuidString,
                sessionTTL: 39
            )),
            makeSessionKeyResult: .success(.init(
                sessionKeyValue: sessionKeyValue
            ))
        )
        
        expect(sut, toDeliver: .success(.init(
            sessionID: .init(sessionIDValue: sessionIDValue),
            sessionKey: .init(sessionKeyValue: sessionKeyValue),
            sessionTTL: sessionTTL
        )))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        prepareKeyExchangeResult: SUT.PrepareKeyExchangeResult = anySuccess(),
        processResult: SUT.ProcessResult = anySuccess(),
        makeSessionKeyResult: SUT.MakeSessionKeyResult = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            prepareKeyExchange: { completion in
                
                completion(prepareKeyExchangeResult)
            },
            process: { _, completion in
                
                completion(processResult)
            },
            makeSessionKey: { _, completion in
                
                completion(makeSessionKeyResult)
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
                    
                case let (
                    .serviceError(expected),
                    .serviceError(received)
                ):
                    switch (expected, received) {
                    case (.activationFailure, .activationFailure),
                        (.makeSessionKeyFailure, .makeSessionKeyFailure),
                        (.missingRSAPublicKey, .missingRSAPublicKey),
                        (.prepareKeyExchangeFailure, .prepareKeyExchangeFailure):
                        break
                        
                    default:
                        XCTFail("Expected \(expected), but got \(received)", file: file, line: line)
                    }
                    
                default:
                    XCTFail("Expected \(expected), but got \(received)", file: file, line: line)
                }
                
            case let (
                .success(expected),
                .success(received)
            ):
                XCTAssertNoDiff(expected.equatable, received.equatable, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension SUT.Success {
    
    var equatable: EquatableSuccess {
        
        .init(
            sessionIDValue: sessionID.sessionIDValue,
            sessionKeyValue: sessionKey.sessionKeyValue,
            sessionTTL: sessionTTL
        )
    }
    
    struct EquatableSuccess: Equatable {
        
        public let sessionIDValue: String
        public let sessionKeyValue: Data
        public let sessionTTL: Int

    }
}

private func anySuccess(
    data: Data = anyData()
) -> SUT.PrepareKeyExchangeResult {
    
    .success(data)
}

private func anySuccess(
    sessionID: String = UUID().uuidString,
    publicServerSessionKey: String = UUID().uuidString,
    sessionTTL: Int = 42
) -> SUT.ProcessResult {
    
    .success(.init(
        sessionID: sessionID,
        publicServerSessionKey: publicServerSessionKey,
        sessionTTL: sessionTTL
    ))
}

private func anySuccess(
    sessionKeyValue: Data = anyData()
) -> SUT.MakeSessionKeyResult {
    
    .success(.init(sessionKeyValue: sessionKeyValue))
}
