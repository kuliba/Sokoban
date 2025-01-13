//
//  RequestCollectorBundlerTests.swift
//
//
//  Created by Igor Malyarov on 25.08.2024.
//

import CombineSchedulers
import VortexTools
import XCTest

final class RequestCollectorBundlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallPerformRequest() {
        
        let (_,_, performRequest) = makeSUT()
        
        XCTAssertEqual(performRequest.callCount, 0)
    }
    
    // MARK: - process
    
    func test_process_shouldNotCallPerformRequestWithSameRequestWithinCollectionPeriod() {
        
        let request = makeRequest()
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: .milliseconds(100)
        )
        
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        
        scheduler.advance(by: .milliseconds(99))
        
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
        
        scheduler.advance(by: .init(collectionPeriod))
        
        XCTAssertEqual(performRequest.callCount, 1)
    }
    
    func test_process_shouldCallPerformRequestOnceForMultipleCollectionPeriodsOnNoResultDelivered() {
        
        let request = makeRequest()
        let collectionPeriod: DispatchTimeInterval = .milliseconds(100)
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: collectionPeriod
        )
        
        scheduler.advance(by: .milliseconds(50))
        sut.process(request) { _ in }

        XCTAssertEqual(performRequest.callCount, 0)

        scheduler.advance(by: .milliseconds(100))
        sut.process(request) { _ in }

        XCTAssertEqual(performRequest.callCount, 1)

        scheduler.advance(by: .milliseconds(150))
        sut.process(request) { _ in }

        XCTAssertEqual(performRequest.callCount, 1)

        scheduler.advance(by: .milliseconds(200))
        sut.process(request) { _ in }
                
        XCTAssertEqual(performRequest.callCount, 1)
    }
    
    func test_process_shouldCallPerformRequestOnceForEachCollectionPeriodsOnResultDelivered() {
        
        let request = makeRequest()
        let collectionPeriod: DispatchTimeInterval = .milliseconds(100)
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: collectionPeriod
        )
        
        scheduler.advance(by: .milliseconds(50))
        sut.process(request) { _ in }

        XCTAssertEqual(performRequest.callCount, 0)

        scheduler.advance(by: .milliseconds(100))
        sut.process(request) { _ in }

        XCTAssertEqual(performRequest.callCount, 1)
        
        performRequest.complete(with: makeResponse())
        wait(timeout: 0.01) // wait for RequestBundler queue

        scheduler.advance(by: .milliseconds(150))
        sut.process(request) { _ in }

        XCTAssertEqual(performRequest.callCount, 1)

        scheduler.advance(by: .milliseconds(200))
        sut.process(request) { _ in }
                
        XCTAssertEqual(performRequest.callCount, 2)
    }
    
    func test_process_shouldNotCallPerformRequestWithDifferentRequestsWithinCollectionPeriod() {
        
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: .milliseconds(100)
        )
        
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        sut.process(makeRequest()) { _ in }
        
        scheduler.advance(by: .milliseconds(99))
        
        XCTAssertEqual(performRequest.callCount, 0)
    }
    
    func test_process_shouldCallPerformRequestWithDifferentRequestsAfterCollectionPeriod() {
        
        let (request1, request2) = (makeRequest(), makeRequest())
        let collectionPeriod: DispatchTimeInterval = .milliseconds(100)
        let (sut, scheduler, performRequest) = makeSUT(
            collectionPeriod: collectionPeriod
        )
        
        sut.process(request1) { _ in }
        sut.process(request2) { _ in }
        
        scheduler.advance(by: .init(collectionPeriod))
        
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
        
        scheduler.advance(by: .init(collectionPeriod))
        
        performRequest.complete(with: response)
        wait(timeout: 0.01) // wait for RequestBundler queue
        
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
