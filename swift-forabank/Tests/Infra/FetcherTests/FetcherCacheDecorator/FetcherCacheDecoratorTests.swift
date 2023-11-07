//
//  FetcherCacheDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

import Fetcher
import XCTest

final class FetcherCacheDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, cacheSpy) = makeSUT()
        
        XCTAssertNoDiff(decoratee.callCount, 0)
        XCTAssertNoDiff(cacheSpy.callCount, 0)
    }
    
    func test_fetch_shouldDeliverErrorOnLoadFailure() {
        
        let loadError = anyError("Load Failure")
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(loadError)], on: {
            
            decoratee.complete(with: .failure(loadError))
        })
    }
    
    func test_fetch_shouldDeliverValueOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut, toDeliver: [.success(item)], on: {
            
            decoratee.complete(with: .success(item))
        })
    }
    
    func test_fetch_shouldPassPayloadToDecoratee() {
        
        let payload = anyRequest()
        let (sut, decoratee, _) = makeSUT()
        
        fetch(sut, payload) {
            
            decoratee.complete(with: .failure(anyError()))
        }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_fetch_shouldNotCacheOnLoadFailure() {
        
        let loadError = anyError("Load Failure")
        let (sut, decoratee, cacheSpy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .failure(loadError)) }
        
        XCTAssertNoDiff(cacheSpy.cachedValues, [])
    }
    
    func test_fetch_shouldCacheValueOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, cacheSpy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .success(item)) }
        
        XCTAssertNoDiff(cacheSpy.cachedValues, [item])
    }
    
    func test_fetch_shouldNotCacheOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: FetcherSpy
        let cacheSpy: CacheSpy<Item>
        (sut, decoratee, cacheSpy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(cacheSpy.cachedValues, [])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetcherCacheDecorator<Request, Item, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: FetcherSpy,
        cacheSpy: CacheSpy<Item>
    ) {
        let decoratee = FetcherSpy()
        let cacheSpy = CacheSpy<Item>()
        let sut = SUT(
            decoratee: decoratee,
            cache: cacheSpy.cache
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        
        return (sut, decoratee, cacheSpy)
    }
    
    private func fetch(
        _ sut: SUT,
        _ payload: Request = anyRequest(),
        on action: @escaping () -> Void
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(payload) { _ in exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResults: [Result<Item, Error>],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [Result<Item, Error>]()
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(anyRequest()) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        _assert(receivedResults, equals: expectedResults, file: file, line: line)
    }
    
    func _assert<T: Equatable, E: Error>(
        _ receivedResults: [Result<T, E>],
        equals expectedResults: [Result<T, E>],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(receivedResults.count, expectedResults.count, "\nExpected \(expectedResults.count) values, bit got \(receivedResults.count).", file: file, line: line)
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(received as NSError),
                    .failure(expected as NSError)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                case let (.success(received), .success(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.1), but got \(element.0).", file: file, line: line)
                }
            }
    }
    
    private func anyItem(
        value: String = UUID().uuidString
    ) -> Item {
        
        .init(value: value)
    }
    
    private final class FetcherSpy: Fetcher {
        
        typealias Payload = Request
        typealias Success = Item
        typealias Failure = Error
        
        typealias Message = (payload: Payload, completion: FetchCompletion)
        
        private var messages = [Message]()
        
        var callCount: Int { messages.count }
        var payloads: [Payload] { messages.map(\.payload) }
        
        func fetch(
            _ payload: Payload,
            completion: @escaping FetchCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: Result<Success, Error>,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class CacheSpy<Value> {
        
        private(set) var cachedValues = [Value]()
        
        var callCount: Int { cachedValues.count }
        
        func cache(_ item: Value) {
            
            cachedValues.append(item)
        }
    }
}

private func anyRequest(
    value: String = UUID().uuidString
) -> Request {
    
    .init(value: value)
}

private struct Request: Equatable {
    
    let value: String
}
private struct Item: Equatable {
    
    let value: String
}

private struct AnyError: Error {
    
    let message: String
}

private func anyError(
    _ message: String = "any error"
) -> Error {
    
    AnyError(message: message)
}
