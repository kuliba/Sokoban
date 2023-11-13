//
//  GetProcessingSessionCodeService+FetcherTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
import Fetcher
@testable import ForaBank
import XCTest

fileprivate typealias SUT = GetProcessingSessionCodeService

final class GetProcessingSessionCodeService_FetcherTests: XCTestCase {
    
    func test_fetch_shouldDeliverErrorOnProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(processResult: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        
        expect(sut, toDeliver: .failure((.invalid(statusCode: statusCode, data: invalidData))))
    }
    
    func test_fetch_shouldDeliverErrorOnProcessNetworkFailure() {
        
        let sut = makeSUT(processResult: .failure(.network))
        
        expect(sut, toDeliver: .failure((.network)))
    }
    
    func test_fetch_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let sut = makeSUT(processResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        
        expect(sut, toDeliver: .failure((.server(statusCode: statusCode, errorMessage: errorMessage))))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        processResult: SUT.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(process: { $0(processResult) })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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

private extension GetProcessingSessionCodeService.Response {
    
    var equatable: EquatableResponse {
        
        .init(code: code, phone: phone)
    }
    
    struct EquatableResponse: Equatable {
        
        let code: String
        let phone: String
    }
}
