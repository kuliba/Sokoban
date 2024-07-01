//
//  BlacklistCacheRetryDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import CombineSchedulers
import ForaTools
import XCTest

final class BlacklistCacheRetryDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, cache, _) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(cache.callCount, 0)
    }
    
    func test_load_shouldCallCacheOnLoadSuccess() {
        
        let response = anyResponse()
        let (sut, decoratee, cache, _) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
            cache.complete(with: .success(()))
            XCTAssertNoDiff(cache.payloads, [response])
        }
    }
    
    func test_load_shouldCallCacheOnSecondRemoteAttempt() {
        
        let response = anyResponse()
        let (sut, decoratee, cache, scheduler) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .success(response), at: 1)
            cache.complete(with: .failure(anyError()))
            XCTAssertNoDiff(cache.payloads, [response])
        }
    }
    
    func test_load_shouldDeliverResponseOnSecondRemoteAttempt() {
        
        let response = anyResponse()
        let (sut, decoratee, cache, scheduler) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .success(response), at: 1)
            cache.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldDeliverLastFailureOnMaxRetryAttempts() {
        
        let maxRetries = 2
        let failure = anyLoadFailure()
        let (sut, decoratee, _, scheduler) = makeSUT(
            isBlacklisted: { _, attempts in return attempts >= 5 },
            retryPolicy: equal(maxRetries: maxRetries, interval: .seconds(1))
        )
        
        assert(sut, with: anyPayload(), toDeliver: .failure(.loadFailure(failure))) {
            
            decoratee.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure()), at: 1)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(failure), at: 2)
        }
        XCTAssertEqual(decoratee.callCount, maxRetries + 1, "Remote call count is one plus retry attempts.")
    }
    
    func test_load_shouldNotDeliverResponseOnSecondAttemptAsBlacklisted() {
        
        let payload = anyPayload()
        let (sut, decoratee, _, scheduler) = makeSUT(
            isBlacklisted: { _, attempts in return attempts >= 2 },
            retryPolicy: equal(maxRetries: 1, interval: .seconds(1))
        )
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("1")))) {
            
            decoratee.complete(with: .failure(anyLoadFailure("0")), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure("1")), at: 1)
        }
        XCTAssertEqual(decoratee.callCount, 2)
        
        assertNoCompletion(sut, with: payload) {
            
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure("2")), at: 2)
        }
        
        assertNoCompletion(sut, with: payload) {
            
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure("3")), at: 3)
        }
    }
    
    func test_load_shouldNotDeliverResponseOnThirdAttemptAsBlacklisted() {
        
        let payload = anyPayload()
        let (sut, decoratee, _, scheduler) = makeSUT(
            isBlacklisted: { _, attempts in return attempts >= 3 },
            retryPolicy: equal(maxRetries: 0, interval: .seconds(1))
        )
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("0")))) {
            
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure("0")), at: 0)
            XCTAssertEqual(decoratee.callCount, 1)
        }
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("1")))) {
            
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure("1")), at: 1)
            XCTAssertEqual(decoratee.callCount, 2)
        }
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("2")))) {
            
            scheduler.advance(to: .init(.now() + .seconds(1)))
            decoratee.complete(with: .failure(anyLoadFailure("2")), at: 2)
            XCTAssertEqual(decoratee.callCount, 3)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BlacklistCacheRetryDecorator<Payload, Response, LoadFailure>
    
    private typealias Cache = Spy<Response, CacheResult>
    private typealias CacheResult = Result<Void, Error>
    
    private typealias Decoratee = Spy<Payload, LoadResult>
    
    private typealias Payload = Int
    private typealias Response = String
    private typealias LoadResult = Result<Response, LoadFailure>
    
    private func makeSUT(
        isBlacklisted: @escaping (Payload, Int) -> Bool = { _,_ in false},
        retryPolicy: RetryPolicy = .onceForSecond,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        cache: Cache,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let decoratee = Decoratee()
        let cache = Cache()
        let scheduler = DispatchQueue.test
        
        let sut = SUT(
            cache: { response, completion in cache.process(response) { _ in completion() }},
            decoratee: decoratee,
            isBlacklisted: isBlacklisted,
            retryPolicy: retryPolicy,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, decoratee, cache, scheduler)
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
    
    private func equal(
        maxRetries: Int,
        interval: DispatchTimeInterval = .seconds(1)
    ) -> RetryPolicy {
        
        return .init(
            maxRetries: maxRetries,
            strategy: .equal(interval: interval)
        )
    }
    
    private func assert(
        _ sut: SUT,
        with payload: Payload,
        toDeliver expected: SUT.BlacklistedResult,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: SUT.BlacklistedResult?
        let exp = expectation(description: "wait for completion")
        
        sut.load(payload) {
            
            result = $0
            exp.fulfill()
        }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(result, expected, file: file, line: line)
    }
    
    private func assertNoCompletion(
        _ sut: SUT,
        with payload: Payload,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.isInverted = true
        
        sut.load(payload) { _ in exp.fulfill() }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private struct LoadFailure: Error, Equatable {
        
        let value: String
    }
}
