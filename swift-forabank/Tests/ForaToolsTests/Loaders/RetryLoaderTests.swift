//
//  RetryLoaderTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import CombineSchedulers
import ForaTools
import XCTest

final class RetryLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_load_shouldCallPerformerWithPayload() {
        
        let payload = anyPayload()
        let (sut, spy, _) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [payload])
    }
    
    func test_load_shouldDeliverSuccessOnPerformerSuccess() {
        
        let response = anyResponse()
        let (sut, spy, _) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            spy.complete(with: .success(response))
        }
    }
    
    func test_load_shouldDeliverFailureOnEmptyRetryIntervals() {
        
        let failure = anyLoadFailure()
        let (sut, spy, _) = makeSUT(retryIntervals: [])
        
        assert(sut, with: anyPayload(), toDeliver: .failure(failure)) {
            
            spy.complete(with: .failure(failure))
        }
    }
    
    func test_load_shouldRetryOnceOnOneRetryInterval() {
        
        let response = anyResponse()
        let (sut, spy, scheduler) = makeSUT(retryIntervals: [.seconds(1)])
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            spy.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            spy.complete(with: .success(response), at: 1)
        }
    }
    
    func test_load_shouldDeliverFailureOnTwoFailuresWithOneRetryInterval() {
        
        let failure = anyLoadFailure()
        let (sut, spy, scheduler) = makeSUT(retryIntervals: [.seconds(1)])
        
        assert(sut, with: anyPayload(), toDeliver: .failure(failure)) {
            
            spy.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            spy.complete(with: .failure(failure), at: 1)
        }
    }
    
    func test_load_shouldRetryTwiceWithTwoIntervals() {
        
        let failure = anyLoadFailure()
        let (sut, spy, scheduler) = makeSUT(
            retryIntervals: [.seconds(1), .seconds(9)]
        )
        
        assert(sut, with: anyPayload(), toDeliver: .failure(failure)) {
            
            spy.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            spy.complete(with: .failure(anyLoadFailure()), at: 1)
            scheduler.advance(to: .init(.now() + .seconds(9)))
            spy.complete(with: .failure(failure), at: 2)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RetryLoader<Payload, Response, LoadFailure>
    private typealias LoadSpy = Spy<Payload, LoadResult>
    
    private typealias Payload = Int
    private typealias Response = String
    private typealias LoadResult = Result<Response, LoadFailure>
    
    private func makeSUT(
        retryIntervals: [DispatchTimeInterval] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LoadSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spy = LoadSpy()
        let scheduler = DispatchQueue.test
        let sut = SUT(
            performer: spy,
            getRetryIntervals: { _ in retryIntervals },
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func anyPayload(
        _ value: Int = .random(in: 0...1_000)
    ) -> Payload {
        
        return value
    }
    
    private func anyResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
        return value
    }
    
    private func anyLoadFailure(
        _ value: String = UUID().uuidString
    ) -> LoadFailure {
        
        return .init(value: value)
    }
    
    private func assert(
        _ sut: SUT,
        with payload: Payload,
        toDeliver expected: LoadResult,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: LoadResult?
        let exp = expectation(description: "wait for completion")
        
        sut.load(payload) {
            
            result = $0
            exp.fulfill()
        }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(result, expected, file: file, line: line)
    }
    
    private struct LoadFailure: Error, Equatable {
        
        let value: String
    }
}
