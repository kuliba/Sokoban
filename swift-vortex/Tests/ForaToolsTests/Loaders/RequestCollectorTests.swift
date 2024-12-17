//
//  RequestCollectorTests.swift
//
//
//  Created by Igor Malyarov on 01.07.2024.
//

import CombineSchedulers
import ForaTools
import XCTest

final class RequestCollectorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - process
    
    func test_process_shouldNotCallCollaboratorOnNoRequests() {
        
        let (_, spy, scheduler) = makeSUT()
        
        scheduler.advance(to: .init(.distantFuture))
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_process_shouldCallCollaboratorOnceWithAllRequestAfterTimeInterval() {
        
        let (request, request2) = (anyRequest(), anyRequest())
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(100))
        
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request2) { _ in }
        sut.process(request2) { _ in }
        XCTAssertTrue(spy.payloads.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(99))))
        XCTAssertTrue(spy.payloads.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(100))))
        XCTAssertNoDiff(spy.payloads.map { Set($0) }, [[request, request2]])
    }
    
    func test_process_shouldNotCallCollaboratorAgainOnRequestAfterTimeIntervalBeforeCollaboratorCompletion() {
        
        let request = anyRequest()
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(100))
        
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        XCTAssertTrue(spy.payloads.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(100))))
        XCTAssertNoDiff(spy.payloads, [[request]])
        
        sut.process(request) { _ in }
        scheduler.advance(to: .init(.distantFuture))
        XCTAssertNoDiff(spy.payloads, [[request]])
    }
    
    func test_process_shouldCallCollaboratorAgainOnRequestAfterTimeIntervalAndCompleted() {
        
        let request = anyRequest()
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(100))
        
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        sut.process(request) { _ in }
        XCTAssertTrue(spy.payloads.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(100))))
        XCTAssertNoDiff(spy.payloads, [[request]])
        spy.complete(with: [request: anyResponse()])
        
        sut.process(request) { _ in }
        scheduler.advance(to: .init(.now().advanced(by: .seconds(99))))
        XCTAssertNoDiff(spy.payloads, [[request]])
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(100))))
        XCTAssertNoDiff(spy.payloads, [[request], [request]])
    }
    
    func test_process_shouldDeliverResponseToMultipleOnSameRequest() {
        
        let (request, response) = (anyRequest(), anyResponse())
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(100))
        var responses = [Response]()
        
        sut.process(request) { responses.append($0) }
        XCTAssertTrue(responses.isEmpty)
        
        sut.process(request) { responses.append($0) }
        XCTAssertTrue(responses.isEmpty)
        
        sut.process(request) { responses.append($0) }
        XCTAssertTrue(responses.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(99))))
        XCTAssertTrue(responses.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(100))))
        spy.complete(with: [request: response])
        
        XCTAssertNoDiff(responses, [response, response, response])
    }
    
    func test_process_shouldDeliverResponses() {
        
        let (request1, request2, request3) = (anyRequest(), anyRequest(), anyRequest())
        let (response1, response2, response3) = (anyResponse(), anyResponse(), anyResponse())
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(1))
        var responses = [Request: Response]()
        
        sut.process(request1) { responses[request1] = $0 }
        XCTAssertTrue(responses.isEmpty)
        
        sut.process(request2) { responses[request2] = $0 }
        XCTAssertTrue(responses.isEmpty)
        
        sut.process(request3) { responses[request3] = $0 }
        XCTAssertTrue(responses.isEmpty)
        
        scheduler.advance(to: .init(.now().advanced(by: .seconds(1))))
        spy.complete(with: [request1: response1, request2: response2, request3: response3])
        
        XCTAssertNoDiff(responses, [request1: response1, request2: response2, request3: response3])
    }
    
    func test_process_shouldHandleHighVolumeRequestLoad() {
        
        let count = 1_000
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(1))
        let exp = expectation(description: "High volume requests")
        exp.expectedFulfillmentCount = count
        
        for i in 1...count {
            
            sut.process(i) { response in
                
                XCTAssertEqual(response, "Response\(i)")
                exp.fulfill()
            }
        }
        scheduler.advance(to: .init(.distantFuture))
        spy.complete(with: makeResponses(count: count))
        
        wait(for: [exp], timeout: 1)
    }
    
    // TODO: fix test - now not working due to mix of scheduler and Dispatch
    func _test_process_shouldHandleConcurrentRequests() {
        
        let count = 10
        let (sut, spy, scheduler) = makeSUT(collectionPeriod: .seconds(1))
        let exp = expectation(description: "Concurrent requests")
        exp.expectedFulfillmentCount = count
        
        let group = DispatchGroup()
        
        for i in 1...10 {
            
            group.enter()
            DispatchQueue.global().async {
                
                sut.process(i) { response in
                    
                    XCTAssertEqual(response, "Response\(i)")
                    exp.fulfill()
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            
            scheduler.advance(to: .init(.distantFuture))
            spy.complete(with: self.makeResponses(count: count))
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RequestCollector<Request, Response>
    private typealias Request = Int
    private typealias Response = String
    
    private typealias PerformRequestsSpy = Spy<[Request], [Request: Response]>
    
    private func makeSUT(
        collectionPeriod: DispatchTimeInterval = .milliseconds(100),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: PerformRequestsSpy,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let spy = PerformRequestsSpy()
        let scheduler = DispatchQueue.test
        let sut = SUT(
            collectionPeriod: collectionPeriod,
            performRequests: spy.process(_:completion:),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
#warning("FIX MEMORY LEAKS")
        //        trackForMemoryLeaks(sut, file: file, line: line)
        //        trackForMemoryLeaks(spy, file: file, line: line)
        //        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func anyRequest(
        _ value: Int = .random(in: 1...1_000)
    ) -> Request {
        
        return value
    }
    
    private func anyResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
        return value
    }
    
    private func makeResponses(
        count: Int
    ) -> [Request: Response] {
        
        return .init(uniqueKeysWithValues: (1...count).map { ($0, "Response\($0)") })
    }
}
