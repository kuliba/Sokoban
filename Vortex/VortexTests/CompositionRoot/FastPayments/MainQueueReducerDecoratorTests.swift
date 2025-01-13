//
//  MainQueueReducerDecoratorTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 10.01.2024.
//

@testable import Vortex
import XCTest

final class MainQueueReducerDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let spy = makeSUT().spy
        
        XCTAssertNoDiff(spy.messages.count, 0)
    }
    
    func test_reduce_shouldForwardState() {
        
        let state = false
        let (sut, spy) = makeSUT()
        
        sut.reduce(false, .start) { _ in }
        spy.complete(with: state)
        
        XCTAssertNoDiff(spy.messages.map(\.state), [state])
    }
    
    func test_reduce_shouldForwardEvent() {
        
        let event: Event = .finish
        let (sut, spy) = makeSUT()
        
        sut.reduce(true, event) { _ in }
        spy.complete(with: false)
        
        XCTAssertNoDiff(spy.messages.map(\.event), [event])
    }
    
    func test_reduce_shouldCompleteOnMainThread() {
        
        let (sut, spy) = makeSUT()
        
        assert(sut) { spy.complete(with: false) }
    }
    
    func test_reduce_shouldCompleteOnMainThreadEvenWhenReducerCompletesOnGlobalQueue() {
        
        let (sut, spy) = makeSUT()
        
        assert(sut) {
            
            DispatchQueue.global().async {
                
                spy.complete(with: false)
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MainQueueReducerDecorator<State, Event>
    private typealias Spy = ReducerSpy<State, Event>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let spy = Spy()
        let sut = SUT(reducer: spy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private typealias State = Bool
    
    private enum Event {
        
        case start, finish
    }
    
    private func assert(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.reduce(true, .start) { _ in
            
            XCTAssert(Thread.isMainThread)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.05)
    }
}

final class ReducerSpy<State, Event>: Reducer {
    
    typealias Message = (state: State, event: Event, completion: (State) -> Void)
    
    private(set) var messages = [Message]()
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        messages.append((state, event, completion))
    }
    
    func complete(
        with state: State,
        at index: Int = 0
    ) {
        messages[index].completion(state)
    }
}
