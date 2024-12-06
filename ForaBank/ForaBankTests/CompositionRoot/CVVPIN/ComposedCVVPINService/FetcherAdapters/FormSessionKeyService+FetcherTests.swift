//
//  FormSessionKeyService+FetcherTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
import Fetcher
@testable import ForaBank
import XCTest

fileprivate typealias SUT = FormSessionKeyService

final class FormSessionKeyService_FetcherTests: XCTestCase {
    
    func test_fetch_shouldDeliverErrorOnMakeSecretRequestJSONFailure() {
        
        let sut = makeSUT(
            makeSecretRequestJSONResult: .failure(anyError())
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
    
    func test_fetch_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let sut = makeSUT(
            processResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_fetch_shouldDeliverErrorOnMakeSessionKeyFailure() {
        
        let sut = makeSUT(
            makeSessionKeyResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.makeSessionKeyFailure)))
    }
    
    func test_fetch_shouldDeliverValueOnSuccess() {
        
        let sessionKeyValue = anyData()
        let eventIDValue = UUID().uuidString
        let sessionTTL = 13
        let sut = makeSUT(
            processResult: .success(.init(
                publicServerSessionKey: UUID().uuidString,
                eventID: eventIDValue,
                sessionTTL: sessionTTL
            )),
            makeSessionKeyResult: .success(.init(
                sessionKeyValue: sessionKeyValue
            ))
        )
        
        expect(sut, toDeliver: .success(.init(
            sessionKey: .init(sessionKeyValue: sessionKeyValue),
            eventID: .init(eventIDValue: eventIDValue),
            sessionTTL: sessionTTL
        )))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        makeSecretRequestJSONResult: SUT.SecretRequestJSONResult = anySuccess(),
        processResult: SUT.ProcessResult = anySuccess(),
        makeSessionKeyResult: SUT.MakeSessionKeyResult = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            makeSecretRequestJSON: { completion in
                
                completion(makeSecretRequestJSONResult)
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
        with code: SUT.Code = anyCode(),
        toDeliver expectedResult: SUT.FetchResult,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(code) { receivedResult in
            
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
                    case (.missingCode, .missingCode),
                        (.makeJSONFailure, .makeJSONFailure),
                        (.makeSessionKeyFailure, .makeSessionKeyFailure):
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
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func anySuccess(
    data: Data = anyData()
) -> SUT.SecretRequestJSONResult {
    
    .success(data)
}

private func anySuccess(
    publicServerSessionKey: String = UUID().uuidString,
    eventID: String = UUID().uuidString,
    sessionTTL: Int = 53
) -> SUT.ProcessResult {
    
    .success(.init(
        publicServerSessionKey: publicServerSessionKey,
        eventID: eventID,
        sessionTTL: sessionTTL
    ))
}

private func anySuccess(
    sessionKeyValue: Data = anyData()
) -> SUT.MakeSessionKeyResult {
    
    .success(.init(sessionKeyValue: sessionKeyValue))
}

private extension FormSessionKeyService.Success {
    
    var equatable: EquatableSuccess {
        
        .init(
            sessionKeyValue: sessionKey.sessionKeyValue,
            eventIDValue: eventID.eventIDValue,
            sessionTTL: sessionTTL
        )
    }
    
    struct EquatableSuccess: Equatable {
        
        public let sessionKeyValue: Data
        public let eventIDValue: String
        public let sessionTTL: Int

    }
}

private func anyCode(
    codeValue: String = UUID().uuidString
) -> FormSessionKeyService.Code {
    
    .init(codeValue: codeValue)
}
