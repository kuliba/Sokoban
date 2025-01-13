//
//  FetchDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 13.11.2023.
//

import Fetcher
import XCTest

final class FetchDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, fetchSpy, handleSpy) = makeSUT()
        
        XCTAssertEqual(fetchSpy.callCount, 0)
        XCTAssertEqual(handleSpy.callCount, 0)
    }
    
    func test_fetch_shouldDeliverFailureOnFetchFailure() {
        
        let (sut, fetchSpy, handleSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(message: "test failure")), on: {
            
            fetchSpy.complete(with: .failure(.init(message: "test failure")))
            handleSpy.complete()
        })
    }
    
    func test_fetch_shouldDeliverSuccessOnFetchSuccess() {
        
        let (sut, fetchSpy, handleSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(value: "a nice item ")), on: {
            
            fetchSpy.complete(with: .success(.init(value: "a nice item ")))
            handleSpy.complete()
        })
    }
    
    func test_fetch_shouldCallHandleResultWithFailureOnFetchFailure() {
        
        let (sut, fetchSpy, handleSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(message: "test failure")), on: {
            
            fetchSpy.complete(with: .failure(.init(message: "test failure")))
            handleSpy.complete()
        })
        _assert(handleSpy.payloads, equals: [.failure(.init(message: "test failure"))])
    }
    
    func test_fetch_shouldCallHandleResultWithSuccessOnFetchSuccess() {
        
        let item = Item(value: "a nice item ")
        let (sut, fetchSpy, handleSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(item), on: {
            
            fetchSpy.complete(with: .success(item))
            handleSpy.complete()
        })
        _assert(handleSpy.payloads, equals: [.success(item)])
    }
    
    func test_fetch_shouldNotCallHandleResultWithFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        let handleSpy: FetchHandleSpy
        (sut, fetchSpy, handleSpy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        fetchSpy.complete(with: .failure(testError()))
        
        XCTAssert(handleSpy.payloads.isEmpty)
    }
    
    func test_fetch_shouldNotCallHandleResultWithSuccessOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        let handleSpy: FetchHandleSpy
        (sut, fetchSpy, handleSpy) = makeSUT()
        
        sut?.fetch(anyRequest()) { _ in }
        sut = nil
        fetchSpy.complete(with: .success(anyItem()))
        
        XCTAssert(handleSpy.payloads.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetchDecorator<Request, Item, TestError>
    private typealias FetchSpy = FetcherSpy<Request, Item, TestError>
    private typealias FetchHandleSpy = HandleSpy<Result<Item, TestError>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fetchSpy: FetchSpy,
        handleSpy: FetchHandleSpy
    ) {
        let fetchSpy = FetchSpy()
        let handleSpy = FetchHandleSpy()
        let sut = SUT(
            fetch: fetchSpy.fetch(_:completion:),
            handleResult: handleSpy.fetch(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(fetchSpy, file: file, line: line)
        trackForMemoryLeaks(handleSpy, file: file, line: line)
        
        return (sut, fetchSpy, handleSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with request: Request = anyRequest(),
        toDeliver expectedResult: SUT.FetchResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(request) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(receivedError),
                .failure(expectedError)
            ):
                XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private final class HandleSpy<Payload> {
        
        typealias Completion = () -> Void
        typealias Message = (payload: Payload, completion: Completion)
        
        private var messages = [Message]()
        
        var callCount: Int { messages.count }
        var payloads: [Payload] { messages.map(\.payload) }
        
        func fetch(
            _ payload: Payload,
            completion: @escaping Completion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(at index: Int = 0) {
            
            messages[index].completion()
        }
    }
}
