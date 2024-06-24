//
//  ResourceLoaderComposerTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import CombineSchedulers
import ForaTools
import XCTest

final class ResourceLoaderComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, local, remote, cache, _) = makeSUT()
        
        XCTAssertEqual(local.callCount, 0)
        XCTAssertEqual(remote.callCount, 0)
        XCTAssertEqual(cache.callCount, 0)
    }
    
    func test_load_shouldDeliverResponseOnLocalLoadSuccess() {
        
        let response = anyResponse()
        let (sut, local, _,_,_) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            local.complete(with: .success(response))
        }
    }
    
    func test_load_shouldDeliverResponseOnSecondRemoteAttempt() {
        
        let response = anyResponse()
        let (sut, local, remote, cache, scheduler) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            local.complete(with: .failure(anyError()))
            remote.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            remote.complete(with: .success(response), at: 1)
            cache.complete(with: .success(()))
        }
    }
    
    func test_load_shouldDeliverLastFailureOnMaxRetryAttempts() {
        
        let maxRetries = 2
        let failure = anyLoadFailure()
        let (sut, local, remote, _, scheduler) = makeSUT(
            isBlacklisted: { _, attempts in return attempts >= 5 },
            retryPolicy: equal(maxRetries: maxRetries, interval: .seconds(1))
        )
        
        assert(sut, with: anyPayload(), toDeliver: .failure(.loadFailure(failure))) {
            
            local.complete(with: .failure(anyError()))
            remote.complete(with: .failure(anyLoadFailure()), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            remote.complete(with: .failure(anyLoadFailure()), at: 1)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            remote.complete(with: .failure(failure), at: 2)
        }
        XCTAssertEqual(remote.callCount, maxRetries + 1, "Remote call count is one plus retry attempts.")
    }
    
    func test_load_shouldNotDeliverResponseOnSecondAttemptAsBlacklisted() {
        
        let payload = anyPayload()
        let (sut, local, remote, _, scheduler) = makeSUT(
            isBlacklisted: { _, attempts in return attempts >= 2 },
            retryPolicy: equal(maxRetries: 1, interval: .seconds(1))
        )
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("2")))) {
            
            local.complete(with: .failure(anyError()), at: 0)
            remote.complete(with: .failure(anyLoadFailure("1")), at: 0)
            scheduler.advance(to: .init(.now() + .seconds(1)))
            remote.complete(with: .failure(anyLoadFailure("2")), at: 1)
        }
        XCTAssertEqual(remote.callCount, 2)
        
        assert(sut, with: payload, toDeliver: .failure(.blacklistedError)) {
            
            local.complete(with: .failure(anyError()), at: 1)
        }
        XCTAssertEqual(remote.callCount, 2)
    }
    
    func test_load_shouldNotDeliverResponseOnThirdAttemptAsBlacklisted() {
        
        let payload = anyPayload()
        let (sut, local, remote, _,_) = makeSUT(
            isBlacklisted: { _, attempts in return attempts >= 3 },
            retryPolicy: equal(maxRetries: 0, interval: .seconds(1))
        )
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("1")))) {
            
            local.complete(with: .failure(anyError()), at: 0)
            remote.complete(with: .failure(anyLoadFailure("1")), at: 0)
        }
        XCTAssertEqual(remote.callCount, 1)
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(anyLoadFailure("2")))) {
            
            local.complete(with: .failure(anyError()), at: 1)
            remote.complete(with: .failure(anyLoadFailure("2")), at: 1)
        }
        XCTAssertEqual(remote.callCount, 2)
        
        assert(sut, with: payload, toDeliver: .failure(.blacklistedError)) {
            
            local.complete(with: .failure(anyError()), at: 1)
        }
        XCTAssertEqual(remote.callCount, 2)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Composer.ComposedLoader
    
    private typealias Composer = ResourceLoaderComposer<Payload, Response, LoadFailure>
    
    private typealias Local = Spy<Payload, Result<Response, Error>>
    private typealias Remote = Spy<Payload, LoadResult>
    
    private typealias Cache = Spy<Response, CacheResult>
    private typealias CacheResult = Result<Void, Error>
    
    private typealias Payload = Int
    private typealias Response = String
    private typealias LoadResult = Result<Response, LoadFailure>
    
    private func makeSUT(
        isBlacklisted: @escaping (Payload, Int) -> Bool = { _,_ in false},
        retryPolicy: RetryPolicy = .init(maxRetries: 1, strategy: .equal(interval: .seconds(1))),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        local: Local,
        remote: Remote,
        cache: Cache,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let local = Local()
        let remote = Remote()
        let cache = Cache()
        let scheduler = DispatchQueue.test
        
        let composer = Composer(
            cache: { response, completion in cache.process(response) { _ in completion() }},
            localLoader: local,
            remoteLoader: remote,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(isBlacklisted: isBlacklisted, retryPolicy: retryPolicy)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(local, file: file, line: line)
        trackForMemoryLeaks(remote, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, local, remote, cache, scheduler)
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
        _ sut: any SUT,
        with payload: Payload,
        toDeliver expected: Composer.BlacklistedResult,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: Composer.BlacklistedResult?
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
