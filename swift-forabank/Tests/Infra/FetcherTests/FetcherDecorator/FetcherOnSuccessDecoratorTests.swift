//
//  FetcherOnSuccessDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

import Fetcher
import XCTest

final class FetcherOnSuccessDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, cacheSpy) = makeSUT()
        
        XCTAssertNoDiff(decoratee.callCount, 0)
        XCTAssertNoDiff(cacheSpy.handledSuccessCount, 0)
    }
    
    func test_fetch_shouldDeliverErrorOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut, payload: anyRequest(), toDeliver: [
            .failure(loadError)
        ], on: {
            decoratee.complete(with: .failure(loadError))
        })
    }
    
    func test_fetch_shouldDeliverValueOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, cacheSpy) = makeSUT()
        
        expect(sut, payload: anyRequest(), toDeliver: [
            .success(item)
        ], on: {
            decoratee.complete(with: .success(item))
            cacheSpy.completeSuccess()
        })
    }
    
    func test_fetch_shouldPassPayloadToDecoratee() {
        
        let payload = anyRequest()
        let (sut, decoratee, _) = makeSUT()
        
        fetch(sut, payload) {
            
            decoratee.complete(with: .failure(testError()))
        }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_fetch_shouldNotCacheOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, cacheSpy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .failure(loadError)) }
        
        XCTAssertNoDiff(cacheSpy.handledSuccessCount, 0)
    }
    
    func test_fetch_shouldCacheValueOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, cacheSpy) = makeSUT()
        
        fetch(sut) {
            
            decoratee.complete(with: .success(item))
            cacheSpy.completeSuccess()
        }
        
        XCTAssertNoDiff(cacheSpy.successMessages.map(\.success), [item])
    }
    
    func test_fetch_shouldNotCacheOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        let cacheSpy: CacheSpy<Item>
        (sut, decoratee, cacheSpy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(cacheSpy.handledSuccessCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetcherDecorator<Request, Item, Error>
    private typealias Decoratee = FetcherSpy<Request, Item, Error>
    private typealias CacheSpy<Value> = HandlerSpy<Value, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        cacheSpy: CacheSpy<Item>
    ) {
        let decoratee = Decoratee()
        let cacheSpy = CacheSpy<Item>()
        let sut = SUT(
            decoratee: decoratee,
            onSuccess: cacheSpy.handleSuccess(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        
        return (sut, decoratee, cacheSpy)
    }
}
