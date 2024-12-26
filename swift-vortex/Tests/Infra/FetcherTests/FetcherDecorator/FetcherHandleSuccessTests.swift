//
//  FetcherHandleSuccessTests.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

import Fetcher
import XCTest

final class FetcherHandleSuccessTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee, spy) = makeSUT()
        
        XCTAssertNoDiff(decoratee.callCount, 0)
        XCTAssertNoDiff(spy.callCount, 0)
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
        let (sut, decoratee, _) = makeSUT()
        
        expect(sut, payload: anyRequest(), toDeliver: [
            .success(item)
        ], on: {
            decoratee.complete(with: .success(item))
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
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .failure(loadError)) }
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_fetch_shouldCacheValueOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) {
            
            decoratee.complete(with: .success(item))
        }
        
        XCTAssertNoDiff(spy.values, [item])
    }
    
    func test_fetch_shouldNotCacheOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: Decoratee
        let spy: HandleSpy
        (sut, decoratee, spy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetcherDecorator<Request, Item, Error>
    private typealias Decoratee = FetcherSpy<Request, Item, Error>
    private typealias HandleSpy = HandleSuccessSpy<Item>
    
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
            handleSuccess: spy.handleValue
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, decoratee, spy)
    }
    
    private final class HandleSuccessSpy<Value> {
        
        private(set) var values = [Value]()
        
        var callCount: Int { values.count }
        
        func handleValue(_ value: Value) {
            
            values.append(value)
        }
    }
}
