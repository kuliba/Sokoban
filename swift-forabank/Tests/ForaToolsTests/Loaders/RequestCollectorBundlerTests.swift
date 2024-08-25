//
//  RequestCollectorBundlerTests.swift
//
//
//  Created by Igor Malyarov on 25.08.2024.
//

import CombineSchedulers
import Foundation

public final class RequestCollectorBundler<Request: Hashable, Response> {
    
    private let requestCollector: RequestCollector<Request, Response>
    
    /// Initialises a new instance of `RequestCollectorBundler`.
    ///
    /// - Parameters:
    ///   - collectionPeriod: The period over which requests are collected before processing.
    ///   - scheduler: The scheduler used to manage the timing of request processing.
    ///   - performRequest: A closure that performs the request and returns the response.
    public init(
        collectionPeriod: DispatchTimeInterval,
        scheduler: AnySchedulerOf<DispatchQueue>,
        performRequest: @escaping RequestBundler<Request, Response>.PerformRequest
    ) {
        self.requestCollector = .init(
            collectionPeriod: collectionPeriod,
            performRequests: { requests, completion in
                
                let bundler = RequestBundler(performRequest: performRequest)
                for request in requests {
                    
                    bundler.load(request) { completion([request: $0]) }
                }
            },
            scheduler: scheduler
        )
    }
}

extension RequestCollectorBundler {
    
    /// Processes a new request by first collecting it, then bundling and executing it.
    ///
    /// - Parameters:
    ///   - request: The request to be processed.
    ///   - completion: The completion handler to be called with the response.
    public func process(
        _ request: Request,
        _ completion: @escaping (Response) -> Void
    ) {
        requestCollector.process(request, completion)
    }
}

#warning("unimplemented: workaround for Void as Request since Void is not Hashable")
//extension RequestCollectorBundler where Request == Void {
//    
//}

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
        
        #warning("restore memory leaks tracking")
//        trackForMemoryLeaks(sut, file: file, line: line)
//        trackForMemoryLeaks(scheduler, file: file, line: line)
//        trackForMemoryLeaks(performRequest, file: file, line: line)
        
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
