//
//  GetProcessingSessionCodeServiceTests.swift
//  
//
//  Created by Igor Malyarov on 30.07.2023.
//

import GetProcessingSessionCodeService
import XCTest

final class GetProcessingSessionCodeServiceTests: XCTestCase {
    
    func test_init_shouldNotFireRequests() {
        
        let spy = makeSUT().spy
        
        XCTAssertTrue(spy.requests.isEmpty)
    }
    
    func test_process_shouldCallHTTPClientWithRequest() {
        
        let (sut, spy) = makeSUT()
        
        sut.process { _ in }
        
        XCTAssertEqual(spy.requests.count, 1)
    }
    
    func test_process_shouldRequestWithGivenURL() {
        
        let givenURL = URL(string: "http://some.url")!
        let (sut, spy) = makeSUT(url: givenURL)
        
        sut.process { _ in }
        
        XCTAssertEqual(spy.requests.map(\.url), [givenURL])
    }
    
    func test_process_shouldRequestWithEmptyData() {
        
        let (sut, spy) = makeSUT()
        
        sut.process { _ in }
        
        XCTAssertEqual(spy.requests.map(\.httpBody), [nil])
    }
    
    func test_process_shouldHaveParticularRequest() {
        
        let givenURL = URL(string: "http://some.url")!
        let (sut, spy) = makeSUT(url: givenURL)
        let request = URLRequest(url: givenURL)
        
        sut.process { _ in }
        
        XCTAssertEqual(spy.requests, [request])
    }
    
    func test_process_shouldDeliverConnectivityErrorOnHTTPClientError() {
        
        let (sut, spy) = makeSUT()
        let httpError = anyError("http error")
        
        expect(sut, toDeliver: [.failure(.connectivity)], on: {
            
            spy.complete(with: httpError)
        })
    }
    
    func test_process_shouldDeliverUnknownStatusCodeErrorOnNon200Non500StatusCode() {
        
        let invalidData = "invalid data".data(using: .utf8)!
        let statusCodes = [199, 201, 300, 400, 499, 501]
        
        statusCodes.forEach { statusCode in
            
            let (sut, spy) = makeSUT()
            let anyValidResponse = anyHTTPURLResponse(with: statusCode)
            
            expect(sut, toDeliver: [.failure(.unknownStatusCode(statusCode))], on: {
                
                spy.complete(with: (invalidData, anyValidResponse))
            })
        }
    }
    
    func test_process_shouldDeliverInvalidDataErrorOnResponseWithStatusCode200WithInvalidData() {
        
        let response200 = anyHTTPURLResponse(with: statusCode200)
        let invalidData = "invalid data".data(using: .utf8)!
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.invalidData(statusCode: statusCode200))], on: {
            
            spy.complete(with: (invalidData, response200))
        })
    }
    
    func test_process_shouldDeliverInvalidDataErrorOnResponseWithStatusCode500WithInvalidData() {
        
        let response500 = anyHTTPURLResponse(with: statusCode500)
        let invalidData = "invalid data".data(using: .utf8)!
        
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.invalidData(statusCode: statusCode500))], on: {
            
            spy.complete(with: (invalidData, response500))
        })
    }
    
    func test_process_shouldDeliverServerErrorOnStatus500WithValidData() {
        
        let serverErrorData = serverErrorData(statusCode: 3001, errorMessage: "Server Error 3001")
        let response500 = anyHTTPURLResponse(with: statusCode500)
        let (sut, spy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serverError(statusCode: 3001, errorMessage: "Server Error 3001"))], on: {
            
            spy.complete(with: (serverErrorData, response500))
        })
    }
    
    func test_process_shouldNotDeliverResultOnSUTInstanceDeallocation() {
        
        var sut: GetProcessingSessionCodeService?
        let spy: HTTPClientSpy
        (sut, spy) = makeSUT()
        let httpError = anyError("http error")
        var results = [SessionCodeDomain.Result]()
        
        sut?.process { results.append($0) }
        sut = nil
        spy.complete(with: httpError)
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = anyURL(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: GetProcessingSessionCodeService,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        let sut = GetProcessingSessionCodeService(
            url: url,
            performRequest: spy.perform
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private let statusCode200 = 200
    private let statusCode500 = 500
    
    private final class HTTPClientSpy {
        
        typealias Completion = SessionCodeDomain.ResponseCompletion
        typealias Message = (request: URLRequest, completion: Completion)
        
        private(set) var messages = [Message]()
        
        var requests: [URLRequest] { messages.map(\.request) }
        
        func perform(
            _ request: URLRequest,
            completion: @escaping Completion
        ) {
            messages.append((request, completion))
        }
        
        func complete(
            with error: Error,
            at index: Int = 0
        ) {
            messages[index].completion(.failure(error))
        }
        
        func complete(
            with response: (Data, HTTPURLResponse),
            at index: Int = 0
        ) {
            messages[index].completion(.success(response))
        }
    }
    
    private func serverErrorData(
        statusCode: Int,
        errorMessage: String
    ) -> Data {
        
        let json: [String: Any] = [
            "statusCode": statusCode,
            "errorMessage": errorMessage
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(
        _ sut: GetProcessingSessionCodeService,
        toDeliver expectedResults: [SessionCodeDomain.Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SessionCodeDomain.Result]()
        
        sut.process { receivedResults.append($0) }
        action()
        
        XCTAssertEqual(expectedResults.count, receivedResults.count, "Expected \(expectedResults.count) results, got \(receivedResults.count) instead.", file: file, line: line)
        
        zip(expectedResults, receivedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (.success(expected), .success(received)):
                    XCTAssertNoDiff(expected, received, "Expected \(expected), received \(received) instead at index \(index).", file: file, line: line)
                    
                case let (.failure(expected), .failure(received)):
                    XCTAssertNoDiff(expected, received, "Expected \(expected), received \(received) instead at index \(index).", file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.0), received \(element.1) instead at index \(index).", file: file, line: line)
                }
            }
    }
}

private func anyError(
    _ domain: String = "any error",
    code: Int = 0
) -> Error {
    
    NSError(domain: domain, code: code)
}
