//
//  RequestBundlerTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import ForaTools
import XCTest

final class RequestBundlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_load_shouldCallPerformerOnFirstRequest() {
        
        let request = anyRequest()
        let (sut, spy) = makeSUT()
        
        sut.load(request) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [request])
    }
    
    func test_load_shouldCallPerformerOnceWithSameRequest() {
        
        let request = anyRequest()
        let (sut, spy) = makeSUT()
        
        sut.load(request) { _ in }
        sut.load(request) { _ in }
        sut.load(request) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [request])
    }
    
    func test_load_shouldCallPerformerWithDifferentRequests() {
        
        let (request1, request2) = (anyRequest(), anyRequest())
        let (sut, spy) = makeSUT()
        
        sut.load(request1) { _ in }
        sut.load(request1) { _ in }
        sut.load(request2) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [request1, request2])
    }
    
    func test_load_shouldDeliverResponses() {
        
        let (request, response) = (anyRequest(), anyResponse())
        var responses = [Response]()
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 3
        
        sut.load(request) { responses.append($0); exp.fulfill() }
        sut.load(request) { responses.append($0); exp.fulfill() }
        sut.load(request) { responses.append($0); exp.fulfill() }
        
        spy.complete(with: response)
        
        wait(for: [exp], timeout: 1)
        XCTAssertNoDiff(responses, [response, response, response])
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldNotDeliverResponseOnInstanceDeallocation() {
        
        let (request, response) = (anyRequest(), anyResponse())
        var responses = [Response]()
        var sut: SUT?
        let spy: LoadSpy
        (sut, spy) = makeSUT()
        
        sut?.load(request) { responses.append($0) }
        sut = nil
        spy.complete(with: response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertTrue(responses.isEmpty)
    }

    // MARK: - Helpers
    
    private typealias SUT = RequestBundler<Request, Response>
    private typealias LoadSpy = Spy<Request, Response>
    
    private typealias Request = Int
    private typealias Response = String
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LoadSpy
    ) {
        let spy = LoadSpy()
        let sut = SUT(performer: spy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyRequest(
        _ value: Int = .random(in: 0...1_000)
    ) -> Request {
        
        return value
    }
    
    private func anyResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
        return value
    }
}
