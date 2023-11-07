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
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_fetch_shouldDeliverErrorOnLoadFailure() {
        
        let loadError = testError("Load Failure")
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
            
            decoratee.complete(with: .failure(testError()))
        }
        
        XCTAssertNoDiff(decoratee.payloads, [payload])
    }
    
    func test_fetch_shouldNotHandleSuccessOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .failure(loadError)) }
        
        XCTAssertNoDiff(spy.handledSuccesses, [])
    }
    
    func test_fetch_shouldHandleSuccessOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .success(item)) }
        
        XCTAssertNoDiff(spy.handledSuccesses, [item])
    }
    
    func test_fetch_shouldNotHandleSuccesOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: FetcherSpy
        let spy: Spy
        (sut, decoratee, spy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(spy.handledSuccesses, [])
    }
    
    func test_fetch_shouldHandleFailureOnLoadFailure() {
        
        let loadError = testError("Load Failure")
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .failure(loadError)) }
        
        XCTAssertNoDiff(spy.handledFailures, [loadError])
    }
    
    func test_fetch_shouldNotHandleFailureOnLoadSuccess() {
        
        let item = anyItem()
        let (sut, decoratee, spy) = makeSUT()
        
        fetch(sut) { decoratee.complete(with: .success(item)) }
        
        XCTAssertNoDiff(spy.handledFailures, [])
    }
    
    func test_fetch_shouldNotHandleFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let decoratee: FetcherSpy
        let spy: Spy
        (sut, decoratee, spy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        decoratee.complete(with: .success(anyItem()))
        
        XCTAssertNoDiff(spy.handledFailures, [])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetcherCacheDecorator<Request, Item, TestError>
    private typealias Spy = DecoratorSpy<Item, TestError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: FetcherSpy,
        spy: Spy
    ) {
        let decoratee = FetcherSpy()
        let spy = Spy()
        let sut = SUT(
            decoratee: decoratee,
            handleSuccess: spy.handleSuccess(_:),
            handleFailure: spy.handleFailure(_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, decoratee, spy)
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
        toDeliver expectedResults: [Result<Item, TestError>],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [Result<Item, TestError>]()
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
        typealias Failure = TestError
        
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
            with result: Result<Success, TestError>,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class DecoratorSpy<Success, Failure: Error> {
        
        private(set) var handledSuccesses = [Success]()
        private(set) var handledFailures = [Failure]()
        
        var callCount: Int {
        
            handledSuccesses.count + handledFailures.count
        }
        
        func handleSuccess(_ success: Success) {
            
            handledSuccesses.append(success)
        }
        
        func handleFailure(_ failure: Failure) {
            
            handledFailures.append(failure)
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

private struct TestError: Error & Equatable {
    
    let message: String
}

private func testError(
    _ message: String = "any error"
) -> TestError {
    
    TestError(message: message)
}
