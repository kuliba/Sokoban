//
//  Services+getCardStatementServiceTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 17.01.2024.
//

@testable import ForaBank
import CardStatementAPI
import GenericRemoteService
import XCTest

final class Services_getCardStatementServiceTests: XCTestCase {
        
    func test_getCardStatementData_statusOkEmptyData_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        try expect(sut, toDeliver: .failure(.mappingFailure(.defaultErrorMessage))) {
            spy.complete(with: .success(makeSuccessResponse(with: .emptyData)))
        }
    }
    
    func test_getCardStatementData_statusOkErrorData_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        try expect(sut, toDeliver: .failure(.mappingFailure(.defaultErrorMessage))) {
            spy.complete(with: .success(makeSuccessResponse(with: .errorData)))
        }
    }

    func test_getCardStatementData_statusNotOk_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        try expect(sut, toDeliver: .failure(.mappingFailure("server error"))) {
            spy.complete(with: .success(makeSuccessResponse(
                with: .emptyData,
                statusCode: 1
            )))
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Services.GetCardStatementService,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        
        let sut = Services.getCardStatementForPeriod (
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
    
    private typealias Payload =  CardStatementAPI.CardStatementForPeriodPayload
    
    private func expect(
        _ sut: Services.GetCardStatementService,
        toDeliver expectedResult: Services.GetCardStatementResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        let exp = expectation(description: "wait for completion")
        let testPeriod = try testPeriod()
        let payload = Payload(
            id: 1,
            name: "cardName",
            period: testPeriod,
            statementFormat: .csv,
            cardNumber: "1111",
            operationType: nil,
            operationGroup: nil,
            includeAdditionalCards: nil
        )
        
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
    
    private func testPeriod() throws -> Payload.Period {
        
        let calendar = Calendar.current
        
        let startDate = try XCTUnwrap(Date.date(year: 2022, month: 4, day: 10, calendar: calendar))
        let endDate = try XCTUnwrap(Date.date(year: 2022, month: 5, day: 10, calendar: calendar))
        
        return .init(start: startDate, end: endDate)
    }
}

private extension String {
    
    static let emptyData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": null
    }
"""
    static let errorData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {}
    }
"""
}
