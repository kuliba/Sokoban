//
//  Services+getScenarioQRDataTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 02.10.2023.
//

@testable import Vortex
import GenericRemoteService
import XCTest

final class ServicesGetScenarioQRDataTests: XCTestCase {
    
    func test_getScenarioQRData_success() throws {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.success(.success(.init(qrcId: "111", parameters: .parameters, required: ["debit_account"])))]) {
            spy.complete(with: .success(makeSuccessResponse()))
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
        sut: Services.GetScenarioQRData,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        
        let sut = Services.getScenarioQRData (
            httpClient: spy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeSuccessResponse() -> (Data, HTTPURLResponse) {
        
        return (
            makeSuccessResponseData(),
            makeHTTPURLResponse(statusCode: 200)
        )
    }
    
    private func makeSuccessResponseData() -> Data {
        
        String.sample.data(using: .utf8)!
    }
    
    private func makeHTTPURLResponse(
        statusCode: Int
    ) -> HTTPURLResponse {
        
        .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    typealias Result = Swift.Result<Services.GetScenarioResult, RemoteServiceError<Error, Error, Error>>
    
    private func expect(
        _ sut: Services.GetScenarioQRData,
        toDeliver expectedResults: [Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [Result]()
        let exp = expectation(description: "wait for completion")
        
        sut.process((QRLink(link: "link"))) { result in
            
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

private extension Array where Element == AnyPaymentParameter {
    
    static let parameters: Self = [
        .init(PaymentParameterHeader(
            id: "title", value: "Оплата по QR-коду")),
        .init(PaymentParameterInfo(
            id: "amount",
            value: "1 ₽",
            title: "Сумма",
            icon:  PaymentParameterInfo.Icon(
                type: .local, value: "ic24IconMessage")))
    ]
}
