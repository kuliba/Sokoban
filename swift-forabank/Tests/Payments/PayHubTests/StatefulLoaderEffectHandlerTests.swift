//
//  StatefulLoaderEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// A handler responsible for executing effects and dispatching corresponding events
/// based on the results of those effects in the `StatefulLoader`.
final class StatefulLoaderEffectHandler {
    
    /// A closure that performs the loading operation.
    /// The closure accepts a callback that should be invoked with `true` if the load
    /// succeeds and `false` if it fails.
    private let load: Load
    
    /// Initialises the `StatefulLoaderEffectHandler` with a specific load operation.
    /// - Parameter load: A closure that performs the load operation and provides the
    /// result via a callback.
    init(
        load: @escaping Load
    ) {
        self.load = load
    }
    
    /// Typealias representing the load operation, which takes a completion closure
    /// that should be called with a `Bool` indicating the success (`true`) or failure (`false`) of the operation.
    typealias Load = (@escaping (Bool) -> Void) -> Void
}

extension StatefulLoaderEffectHandler {
    
    /// Handles the given effect and dispatches events based on the outcome of the effect.
    /// - Parameters:
    ///   - effect: The effect to handle, which in this case is typically a `load` operation.
    ///   - dispatch: A closure used to dispatch events such as `loadSuccess` or `loadFailure`
    ///   based on the result of the effect.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load { success in
                if success {
                    dispatch(.loadSuccess)
                } else {
                    dispatch(.loadFailure)
                }
            }
        }
    }
}

extension StatefulLoaderEffectHandler {
    
    /// Typealias representing the dispatch closure used to send events back to the reducer.
    typealias Dispatch = (Event) -> Void
    
    /// Typealias for the events that can be dispatched by the effect handler.
    typealias Event = StatefulLoaderEvent
    
    /// Typealias for the effects that can be handled by the effect handler.
    typealias Effect = StatefulLoaderEffect
}

import XCTest

final class StatefulLoaderEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, loadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoad() {
        
        let (sut, loadSpy) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldDeliverLoadFailureEvent() {
        
        let (sut, loadSpy) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loadFailure) {
            
            loadSpy.complete(with: false)
        }
    }
    
    func test_load_shouldDeliverLoadSuccessEvent() {
        
        let (sut, loadSpy) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loadSuccess) {
            
            loadSpy.complete(with: true)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = StatefulLoaderEffectHandler
    private typealias LoadSpy = Spy<Void, Bool>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let sut = SUT(load: loadSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
