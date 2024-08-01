//
//  RequestPoolerTests.swift
//
//
//  Created by Igor Malyarov on 11.03.2024.
//

import ForaTools
import XCTest

final class RequestPoolerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_handleRequest_shouldCallCollaboratorOnceForSameRequests() {
        
        let request = makeRequest()
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 3
        
        sut.handleRequest(request) { _ in exp.fulfill() }
        sut.handleRequest(request) { _ in exp.fulfill() }
        sut.handleRequest(request) { _ in exp.fulfill() }
        spy.complete(with: makeResponse())
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(spy.payloads.count, 1)
        XCTAssertEqual(spy.payloads, [request])
    }
    
    func test_handleRequest_shouldCallCollaboratorTwiceIfSameRequestComeAfterResponseDelivered() {
        
        let request = makeRequest()
        let (sut, spy) = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 3
        
        sut.handleRequest(request) { _ in exp.fulfill() }
        sut.handleRequest(request) { _ in exp.fulfill() }
        spy.complete(with: makeResponse())
        
        sut.handleRequest(request) { _ in exp.fulfill() }
        spy.complete(with: makeResponse())
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(spy.payloads.count, 2)
        XCTAssertEqual(spy.payloads, [request, request])
    }
    
    func test_handleRequest_shouldCallCollaboratorWithDifferentRequests() {
        
        let firstRequest = makeRequest()
        let lastRequest = makeRequest()
        let (sut, spy) = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 2
        
        sut.handleRequest(firstRequest) { _ in exp.fulfill() }
        sut.handleRequest(firstRequest) { _ in exp.fulfill() }
        spy.complete(with: makeResponse())
        
        sut.handleRequest(lastRequest) { _ in exp.fulfill() }
        spy.complete(with: makeResponse())
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(spy.payloads.count, 2)
        XCTAssertEqual(spy.payloads, [firstRequest, lastRequest])
    }
    
    func test_handleRequest_shouldDeliverSameResponseForAllClientsWithSameRequest() {
        
        let request = makeRequest()
        let response = makeResponse()
        let (sut, spy) = makeSUT()
        
        var responses = [Response]()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 2
        
        sut.handleRequest(request) {
            
            responses.append($0)
            exp.fulfill()
        }
        sut.handleRequest(request) {
            
            responses.append($0)
            exp.fulfill()
        }
        spy.complete(with: response)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(responses, [response, response])
    }
    
    func test_handleRequest_shouldDeliverResponsesCorrespondingToRequests() {
        
        let (firstRequest, firstResponse) = (makeRequest(), makeResponse())
        let (lastRequest, lastResponse) = (makeRequest(), makeResponse())
        let (sut, spy) = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 2
        var first: Response?
        var last: Response?
        
        sut.handleRequest(firstRequest) {
            
            first = $0
            exp.fulfill()
        }
        sut.handleRequest(lastRequest) {
            
            last = $0
            exp.fulfill()
        }
        spy.complete(with: lastResponse, at: 1)
        spy.complete(with: firstResponse, at: 0)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(first, firstResponse)
        XCTAssertNoDiff(last, lastResponse)
    }
    
    func test_handleRequest_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let spy: PerformSpy
        (sut, spy) = makeSUT()
        
        var responses = [Response]()
        
        sut?.handleRequest(makeRequest()) { responses.append($0) }
        sut = nil
        spy.complete(with: makeResponse())
        
        XCTAssertEqual(responses, [])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RequestPooler<Request, Response>
    private typealias PerformSpy = Spy<Request, Response>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: PerformSpy
    ) {
        let spy = PerformSpy()
        let sut = SUT(perform: spy.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeRequest(
        _ id: String = UUID().uuidString
    ) -> Request {
        
        .init(id: id)
    }
    
    private func makeResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
        .init(value: value)
    }
    
    private struct Request: Hashable {
        
        var id: String
        
        init(id: String = UUID().uuidString) {
            
            self.id = id
        }
    }
    
    private struct Response: Equatable {
        
        var value: String
        
        init(value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
}
