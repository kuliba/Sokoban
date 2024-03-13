//
//  Services_getProductListByTypeServiceTests.swift
//  ForaBankTests
//
//  Created by Disman Dmitry on 11.03.2024.
//

@testable import ForaBank
import GenericRemoteService
import XCTest

final class Services_getProductListByTypeServiceTests: XCTestCase {
        
    #warning("Тесты")
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Services.GetProductListByTypeService,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        
        let sut = Services.makeGetProductListByTypeService(
            httpClient: spy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeSuccessResponse(
        with string: String,
        statusCode: Int = 200
    ) -> (Data, HTTPURLResponse) {
        
        return (
            makeSuccessResponseData(with: string),
            anyHTTPURLResponse(with: statusCode)
        )
    }
    
    private func makeSuccessResponseData(
        with string: String
    ) -> Data {
        
        string.data(using: .utf8)!
    }
    
    private typealias Payload = Services.GetProductListByTypePayload
    
    private func expect(
        _ sut: Services.GetProductListByTypeService,
        toDeliver expectedResult: Services.GetProductListByTypeResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        let exp = expectation(description: "wait for completion")
        let payload = Payload.account
        
        sut.process(payload) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(receivedError as NSError),
                .failure(expectedError as NSError)
            ):
                XCTAssertNoDiff(
                    receivedError,
                    expectedError,
                    "Expected \(expectedError), got \(receivedError) instead.",
                    file: file, line: line
                )
                
            case let (
                .success(.failure(receivedError as NSError)),
                .failure(expectedError as NSError)
            ):
                XCTAssertNoDiff(
                    receivedError,
                    expectedError,
                    "Expected \(expectedError), got \(receivedError) instead.",
                    file: file, line: line
                )


            case let (
                .success(.success(receivedData)),
                .success(expectedData)
            ):
                XCTAssertNoDiff(
                    receivedData,
                    expectedData,
                    "Expected \(expectedData), got \(receivedData) instead.",
                    file: file, line: line
                )
             
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
