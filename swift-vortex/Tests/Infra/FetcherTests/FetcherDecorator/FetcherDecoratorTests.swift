//
//  FetcherDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

import Fetcher
import XCTest

final class FetcherDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, spy) = makeSUT()
        
        XCTAssertNoDiff(decoratee.callCount, 0)
        XCTAssertNoDiff(spy.handledSuccessCount, 0)
        XCTAssertNoDiff(spy.handledFailureCount, 0)
    }
    
    func test_fetch_shouldDeliverErrorOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, spy) = makeSUT()
        
        expect(sut, payload: anyRequest(), toDeliver: [
            .failure(loadError)
        ], on: {
            decoratee.complete(with: .failure(loadError))
            spy.completeFailure()
        })
    }
    
    func test_fetch_shouldDeliverValueOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()
        
        expect(sut, payload: anyRequest(), toDeliver: [
            .success(item)
        ], on: {
            decoratee.complete(with: .success(item))
            spy.completeSuccess()
        })
    }
    
    func test_fetch_shouldPassPayloadToDecorateeOnFailure() {
        
        let payload = anyRequest()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut, payload) {
            
            decoratee.complete(with: .failure(testError()))
            spy.completeFailure()
        }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_fetch_shouldPassPayloadToDecorateeOnSuccess() {
        
        let payload = anyRequest()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut, payload) {
            
            decoratee.complete(with: .success(anyItem()))
            spy.completeSuccess()
        }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_fetch_shouldNotHandleSuccessOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) {
            
            decoratee.complete(with: .failure(loadError))
            spy.completeFailure()
        }
        
        XCTAssertNoDiff(spy.handledSuccessCount, 0)
    }
    
    func test_fetch_shouldHandleSuccessOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) {
            
            decoratee.complete(with: .success(item))
            spy.completeSuccess()
        }
        
        XCTAssertNoDiff(spy.successMessages.map(\.success), [item])
    }
    
    func test_fetch_shouldNotHandleSuccesOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        let spy: HandleSpy
        (sut, decoratee, spy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(spy.handledSuccessCount, 0)
    }
    
    func test_fetch_shouldHandleFailureOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) {
            
            decoratee.complete(with: .failure(loadError))
            spy.completeFailure()
        }
        
        XCTAssertNoDiff(spy.failureMessages.map(\.failure), [loadError])
    }
    
    func test_fetch_shouldNotHandleFailureOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) {
            
            decoratee.complete(with: .success(item))
            spy.completeSuccess()
        }
        
        XCTAssertNoDiff(spy.handledFailureCount, 0)
    }
    
    func test_fetch_shouldNotHandleFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        let spy: HandleSpy
        (sut, decoratee, spy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(spy.handledFailureCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetcherDecorator<Request, Item, TestError>
    private typealias Decoratee = FetcherSpy<Request, Item, TestError>
    private typealias HandleSpy = HandlerSpy<Item, TestError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: Decoratee,
        spy: HandleSpy
    ) {
        let decoratee = Decoratee()
        let spy = HandleSpy()
        let sut = SUT(
            decoratee: decoratee,
            onSuccess: spy.handleSuccess,
            onFailure: spy.handleFailure
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, decoratee, spy)
    }
}
