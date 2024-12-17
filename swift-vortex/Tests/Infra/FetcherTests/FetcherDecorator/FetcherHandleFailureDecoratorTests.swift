//
//  FetcherHandleFailureDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 06.11.2023.
//

import Fetcher
import XCTest

final class FetcherHandleFailureDecoratorTests: XCTestCase {
    
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

    func test_fetch_shouldHandleFailureOnLoadFailure() {

        let loadError = testError("Load Failure")
        let (sut, decoratee, spy) = makeSUT()

        fetch(sut) {

            decoratee.complete(with: .failure(loadError))
        }

        XCTAssertNoDiff(spy.failures, [loadError])
    }

    func test_fetch_shouldNotHandleFailureOnLoadSuccess() {

        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()

        fetch(sut) { decoratee.complete(with: .success(item)) }

        XCTAssertNoDiff(spy.callCount, 0)
    }

    func test_fetch_shouldNotHandleFailureOnInstanceDeallocation() {

        var sut: SUT?
        let decoratee: Decoratee
        let spy: HandleSpy
        (sut, decoratee, spy) = makeSUT()

        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .failure(testError()))

        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetcherDecorator<Request, Item, TestError>
    private typealias Decoratee = FetcherSpy<Request, Item, TestError>
    private typealias HandleSpy = HandleFailureSpy<TestError>
    
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
            handleFailure: spy.handleFailure
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, decoratee, spy)
    }
    
    private final class HandleFailureSpy<Failure: Error> {
        
        private(set) var failures = [Failure]()
        
        var callCount: Int { failures.count }
        
        func handleFailure(_ failure: Failure) {
            
            failures.append(failure)
        }
    }
}
