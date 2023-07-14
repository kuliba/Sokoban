//
//  LoadableResourceViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 23.06.2023.
//

import Combine
import LoadableResourceComponent
import XCTest

final class LoadableResourceViewModelTests: XCTestCase {
    
    func test_init_shouldSetStateToLoading() {
        
        let publisher = Fail<TestResource, Error>(error: anyNSError()).eraseToAnyPublisher()
        let (sut, spy, _) = makeSUT(publisher: publisher)
        
        assertEqual(spy.values, [.loading])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetStateToErrorOnLoaderFailure() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(completion: .failure(anyNSError()))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
    }
    
    func test_shouldSetStateToErrorOnceOnLoaderFailureTwice() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(completion: .failure(anyNSError()))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
        
        subject.send(completion: .failure(anyNSError()))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
    }
    
    func test_shouldSetStateToErrorOnLoaderSuccessAfterFailure() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(completion: .failure(anyNSError()))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
        
        subject.send(.init(id: 2))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
    }
    
    func test_shouldSetStateToLoadedResultOnLoaderSuccess() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
        ])
    }
    
    func test_shouldSetStateToLoadedResultOnLoaderSuccesses() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
        ])
        
        subject.send(.init(id: 2))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
            .loaded(.init(id: 2)),
        ])
    }
    
    func test_shouldSetStateToLoadedResultTwiceOnSameLoaderSuccess() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
            .loaded(.init(id: 1)),
        ])
    }
    
    func test_shouldSetStateToLoadedResultThenErrorOnLoaderFailureAfterSuccess() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher()
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
        ])
        
        subject.send(completion: .failure(anyNSError()))
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
            .error(anyNSError()),
        ])
    }
    
    func test_shouldSetStateOnDelayedLoader() {
        
        let subject = PassthroughSubject<TestResource, Error>()
        let (_, spy, scheduler) = makeSUT(
            publisher: subject.eraseToAnyPublisher(),
            delayMS: 100
        )
        
        scheduler.advance()
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance(by: .milliseconds(99))
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
        ])
        
        subject.send(.init(id: 1))
        scheduler.advance(by: .milliseconds(100))
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
            .loaded(.init(id: 1)),
        ])
        
        subject.send(.init(id: 2))
        scheduler.advance(by: .milliseconds(100))
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
            .loaded(.init(id: 1)),
            .loaded(.init(id: 2)),
        ])
        
        subject.send(completion: .failure(anyNSError()))
        scheduler.advance(by: .milliseconds(100))
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 1)),
            .loaded(.init(id: 1)),
            .loaded(.init(id: 2)),
            .error(anyNSError()),
        ])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias ViewModel = LoadableResourceViewModel<TestResource>
    fileprivate typealias State = ViewModel.State
    
    private func makeSUT(
        publisher: AnyPublisher<TestResource, Error>,
        delayMS: Int = 0,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        spy: ValueSpy<State>,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let publisher = publisher
            .delay(for: .milliseconds(delayMS), scheduler: scheduler)
            .eraseToAnyPublisher()
        let sut = ViewModel(
            publisher: publisher,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        // trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func assertEqual(
        _ received: [State],
        _ expected: [State],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(received.count, expected.count, "Received \(received.count) value(s), but expected \(expected.count).", file: file, line: line)
        
        zip(received, expected).enumerated().forEach { index, value in
            
            let (received, expected) = value
            
            switch (received, expected) {
            case (.loading, .loading):
                break
                
            case let (.error(received), .error(expected)):
                XCTAssertNoDiff(
                    received as NSError,
                    expected as NSError,
                    file: file, line: line
                )
                
            case let (.loaded(received), .loaded(expected)):
                XCTAssertNoDiff(
                    received,
                    expected,
                    file: file, line: line
                )
                
            default:
                XCTFail("Received \(received), but expected \(expected) at index \(index).", file: file, line: line)
            }
        }
    }
}

private struct TestResource: Equatable {
    
    let id: Int
}
