//
//  Services+getCardStatementServiceTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 17.01.2024.
//

@testable import ForaBank
import GenericRemoteService
import XCTest

final class Services_getCardStatementServiceTests: XCTestCase {
    
    func test_getCardStatementData_success() throws {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.success(.success(.init([.sample])))]) {
            spy.complete(with: .success(makeSuccessResponse(with: .sampleCardStatement)))
        }
    }
    
    func test_getCardStatementData_statusOkEmptyData_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.success(.failure(.mapError(.defaultError)))]) {
            spy.complete(with: .success(makeSuccessResponse(with: .emptyData)))
        }
    }
    
    func test_getCardStatementData_statusOkErrorData_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.success(.failure(.mapError(.defaultError)))]) {
            spy.complete(with: .success(makeSuccessResponse(with: .errorData)))
        }
    }

    func test_getCardStatementData_statusNotOk_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.success(.failure(.mapError("server error")))]) {
            spy.complete(with: .success(makeSuccessResponse(
                with: .emptyData,
                statusCode: 1
            )))
        }
    }

    func test_getScenarioQRData_shouldDeliverErrorOnPerformRequestFailure() throws {
        
        let performRequestError = anyError()
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.performRequest(performRequestError))]) {
            spy.complete(with: .failure(performRequestError))
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Services.GetCardStatementData,
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
            makeHTTPURLResponse(statusCode: statusCode)
        )
    }
    
    private func makeSuccessResponseData(
        with string: String
    ) -> Data {
        
        string.data(using: .utf8)!
    }
    
    private func makeHTTPURLResponse(
        statusCode: Int
    ) -> HTTPURLResponse {
        
        .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    typealias Result = Swift.Result<Services.GetCardStatementResult, RemoteServiceError<Error, Error, Error>>
    
    private func expect(
        _ sut: Services.GetCardStatementData,
        toDeliver expectedResults: [Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [Result]()
        let exp = expectation(description: "wait for completion")
        
        sut.process((.init(
            id: 1,
            name: "cardName",
            period: .initialPeriod,
            statementFormat: .csv,
            cardNumber: "1111"))) { result in
                
                results.append(result)
                exp.fulfill()
            }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(results.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(results.count) instead.", file: file, line: line)
        
        zip(results, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (.failure(received), .failure(expected)):
                    switch (received, expected) {
                    case let (.createRequest(received as NSError), .createRequest(expected as NSError)):
                        XCTAssertNoDiff(received, expected, file: file, line: line)
                        
                    case let (.performRequest(received as NSError), .performRequest(expected as NSError)):
                        XCTAssertNoDiff(received, expected, file: file, line: line)
                        
                    case let (.mapResponse(received as NSError), .mapResponse(expected as NSError)):
                        XCTAssertNoDiff(received, expected, file: file, line: line)
                        
                    default:
                        XCTFail("Expected \(expected), got \(received) instead.", file: file, line: line)
                    }
                    
                case let (.success(received), .success(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.1), got \(element.0) instead.", file: file, line: line)
                }
            }
    }
}

private extension String {
    
    static let sampleCardStatement: Self = """
{
  "statusCode": 0,
  "errorMessage": "string",
  "data": [
    {
        "type": "INSIDE",
        "accountID": 100,
        "date": "2001-01-01T00:00:00.000Z",
        "tranDate": "2001-01-01T00:00:00.000Z",
        "operationType": "DEBIT",
        "paymentDetailType": "SFP",
        "amount": 20,
        "documentAmount": 20,
        "comment": "",
        "documentID": 102,
        "accountNumber": "302",
        "currencyCodeNumeric": 810,
        "merchantName": "",
        "merchantNameRus": "merchantNameRus",
        "groupName": "groupName",
        "md5hash": "md5hash",
        "terminalCode": "",
        "deviceCode": "",
        "country": "",
        "city": "",
        "operationId": "105",
        "isCancellation": false,
        "cardTranNumber": "465",
        "opCode": 1,
        "MCC": 0
    }
  ]
}
"""
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

private extension Period {
    
    static let initialPeriod: Self = {
        
        let calendar = Calendar.current
        
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        return Period(start: startDate, end: endDate)
    }()
}

private extension ProductStatementData {
    
    static let sample: Self = .init(
        mcc: 0,
        accountId: 100,
        accountNumber: "302",
        amount: 20,
        cardTranNumber: "465",
        city: "",
        comment: "",
        country: "",
        currencyCodeNumeric: 810,
        date: Date(timeIntervalSince1970: 978307200),
        deviceCode: "",
        documentAmount: 20,
        documentId: 102,
        fastPayment: nil,
        groupName: "groupName",
        isCancellation: false,
        md5hash: "md5hash",
        merchantName: "",
        merchantNameRus: "merchantNameRus",
        opCode: 1,
        operationId: "105",
        operationType: .debit,
        paymentDetailType: .sfp,
        svgImage: nil,
        terminalCode: "",
        tranDate: Date(timeIntervalSince1970: 978307200),
        type: .inside
    )
}
