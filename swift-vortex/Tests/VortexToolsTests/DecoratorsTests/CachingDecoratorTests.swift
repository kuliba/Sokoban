//
//  CachingDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 17.01.2025.
//

import VortexTools
import XCTest

final class CachingDecoratorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, cache) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(cache.callCount, 0)
    }
    
    // MARK: - load
    
    func test_load_shouldCallDecorateeWithPayload() {
        
        let payload = makePayload()
        let (sut, decoratee, _) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_load_shouldNotCallCacheOnDecorateeFailure() {
        
        let (sut, decoratee, cache) = makeSUT()
        
        sut.load(makePayload()) { _ in }
        decoratee.complete(with: nil)
        
        XCTAssertTrue(cache.payloads.isEmpty)
    }
    
    func test_load_shouldCallCacheWithDecorateeSuccess() {
        
        let response = makeResponse()
        let (sut, decoratee, cache) = makeSUT()
        
        sut.load(makePayload()) { _ in }
        decoratee.complete(with: response)
        
        XCTAssertNoDiff(cache.payloads, [response])
    }
    
    func test_load_shouldDeliverFalseOnDecorateeFailure() {
        
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut: sut, toDeliver: false) {
            
            decoratee.complete(with: nil)
        }
    }
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        (sut, decoratee, _) = makeSUT()
        var result: Bool?
        
        sut?.load(makePayload()) { result = $0 }
        sut = nil
        decoratee.complete(with: nil)
        
        XCTAssertNil(result)
    }
    
    func test_load_shouldDeliverFalseOnDecorateeSuccessCacheFailure() {
        
        let (sut, decoratee, cache) = makeSUT()
        
        expect(sut: sut, toDeliver: false) {
            
            decoratee.complete(with: makeResponse())
            cache.complete(with: false)
        }
    }
    
    func test_load_shouldNotDeliverCacheResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        let cache: Cache
        (sut, decoratee, cache) = makeSUT()
        var result: Bool?
        
        sut?.load(makePayload()) { result = $0 }
        decoratee.complete(with: makeResponse())
        sut = nil
        cache.complete(with: false)
        
        XCTAssertNil(result)
    }
    
    func test_load_shouldDeliverTrueOnDecorateeSuccessCacheSuccess() {
        
        let (sut, decoratee, cache) = makeSUT()
        
        expect(sut: sut, toDeliver: true) {
            
            decoratee.complete(with: makeResponse())
            cache.complete(with: true)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CachingDecorator<Payload, Response>
    private typealias Decoratee = Spy<Payload, Response?>
    private typealias Cache = Spy<Response, Bool>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        cache: Cache
    ) {
        let decoratee = Decoratee()
        let cache = Cache()
        let sut = SUT(
            decoratee: decoratee.process,
            cache: cache.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee, cache)
    }
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
    
    private func expect(
        sut: SUT,
        with payload: Payload? = nil,
        toDeliver expected: Bool,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load(payload ?? makePayload()) {
            
            XCTAssertNoDiff($0, expected, "Expected \(expected), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
