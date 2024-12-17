//
//  CacheDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import ForaTools
import XCTest

final class CacheDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
     
        let (_, decoratee, cache) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(cache.callCount, 0)
    }
    
    func test_load_shouldCallDecorateeWithPayload() {
            
        let payload = anyPayload()
        let (sut, decoratee, _) = makeSUT()
        
        sut.load(payload) { _ in }

        XCTAssertNoDiff(decoratee.payloads, [payload])
    }

    func test_load_shouldDeliverDecorateeFailureOnFailure() {
            
        let failure = anyLoadFailure()
        let (sut, decoratee, _) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .failure(failure)) {
            
            decoratee.complete(with: .failure(failure))
        }
    }
    
    func test_load_shouldDeliverDecorateeSuccessOnSuccess() {
            
        let response = anyResponse()
        let (sut, decoratee, cache) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
            cache.complete(with: .success(()))
        }
    }
    
    func test_load_shouldNotCallCacheOnLoadFailure() {
            
        let failure = anyLoadFailure()
        let (sut, decoratee, cache) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .failure(failure)) {
            
            decoratee.complete(with: .failure(failure))
        }

        XCTAssertNoDiff(cache.callCount, 0)
    }
    
    func test_load_shouldCallCacheWithDecorateeSuccessOnSuccess() {
        
        let response = anyResponse()
        let (sut, decoratee, cache) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
            cache.complete(with: .failure(anyError()))
        }
        XCTAssertNoDiff(cache.payloads, [response])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CacheDecorator<Payload, Response, LoadFailure>
    private typealias LoadSpy = Spy<Payload, LoadResult>
    private typealias Cache = Spy<Response, CacheResult>
    
    private typealias Payload = Int
    private typealias Response = String
    private typealias LoadResult = Result<Response, LoadFailure>
    private typealias CacheResult = Result<Void, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: LoadSpy,
        cache: Cache
    ) {
        let decoratee = LoadSpy()
        let cache = Cache()
        let sut = SUT(
            decoratee: decoratee,
            cache: { response, completion in cache.process(response) { _ in completion() }}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        
        return (sut, decoratee, cache)
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
