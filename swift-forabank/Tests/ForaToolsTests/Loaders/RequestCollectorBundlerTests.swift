//
//  RequestCollectorBundlerTests.swift
//
//
//  Created by Igor Malyarov on 25.08.2024.
//

import CombineSchedulers
import ForaTools
import XCTest

final class RequestCollectorBundlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallPerformRequest() {
        
        let (_,_, performRequest) = makeSUT()
        
        XCTAssertEqual(performRequest.callCount, 0)
    }
    
    // MARK: - process
    
    func test_process_shouldNotCallPerformRequestWithinCollectionPeriod() {
        
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: .milliseconds(100)
        )
        
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(99))))
        
        XCTAssertEqual(performRequest.callCount, 0)
    }
    
    func test_process_shouldNotCallPerformRequestWithDifferentRequestsWithinCollectionPeriod() {
        
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: .milliseconds(100)
        )
        
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(99))))
        
        XCTAssertEqual(performRequest.callCount, 0)
    }
    
    func test_process_shouldCallPerformRequestOnceOnSameRequestAfterCollectionPeriod() {
        
        let request = makeRequest()
        let collectionPeriod: DispatchTimeInterval = .milliseconds(100)
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: collectionPeriod
        )
        
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        
        scheduler.advance(to: .init(.now().advanced(by: collectionPeriod)))
        
        XCTAssertEqual(performRequest.callCount, 1)
    }
    
    func test_process_shouldCallPerformRequestWithDifferentRequestsAfterCollectionPeriod() {
        
        let (request1, request2) = (makeRequest(), makeRequest())
        let collectionPeriod: DispatchTimeInterval = .milliseconds(100)
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: collectionPeriod
        )
        
        sut.process(request1) { _ in }
        sut.process(request2) { _ in }
        
        scheduler.advance(to: .init(.now().advanced(by: collectionPeriod)))
        
        XCTAssertNoDiff(Set(performRequest.payloads), [request1, request2])
    }
    
    func test_process_shouldDeliverSameResponseForClientsWithSameRequest() {
        
        let (request, response) = (makeRequest(), makeResponse())
        let collectionPeriod: DispatchTimeInterval = .milliseconds(100)
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: collectionPeriod
        )
        var receivedResponses = [Response]()
        
        sut.process(request) { receivedResponses.append($0) }
        sut.process(request) { receivedResponses.append($0) }
        sut.process(request) { receivedResponses.append($0) }
        
        scheduler.advance(to: .init(.now().advanced(by: collectionPeriod)))
        performRequest.complete(with: response)
        
        // wait for RequestBundler queue
        wait(timeout: 0.01)
        
        XCTAssertNoDiff(receivedResponses, [response, response, response])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RequestCollectorBundler<Request, Response>
    private typealias PerformRequestSpy = Spy<Request, Response>
    
    private func makeSUT(
        collectionPeriod: DispatchTimeInterval = .milliseconds(500),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOf<DispatchQueue>,
        performRequest: PerformRequestSpy
    ) {
        let scheduler = DispatchQueue.test
        let performRequest = PerformRequestSpy()
        let sut = SUT(
            collectionPeriod: collectionPeriod,
            scheduler: scheduler.eraseToAnyScheduler(),
            performRequest: performRequest.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, scheduler, performRequest)
    }
    
    private struct Request: Hashable {
        
        let value: String
    }
    
    private func makeRequest(
        _ value: String = anyMessage()
    ) -> Request {
        
        return .init(value: value)
    }
    
    private struct Response: Hashable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
}
