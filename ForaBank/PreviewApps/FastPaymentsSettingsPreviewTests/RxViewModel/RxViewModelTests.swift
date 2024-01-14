//
//  RxViewModelTests.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

import XCTest

final class RxViewModelTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, reducer, effectHandler) = makeSUT()
        
        XCTAssertNoDiff(reducer.callCount, 0)
        XCTAssertNoDiff(effectHandler.callCount, 0)
    }
    
    func test_event_shouldCallReducerWithGivenStateAndEvent() {
        
        let initialState = makeState()
        let event: Event = .resetValue
        let (sut, reducer, _) = makeSUT(
            initialState: initialState,
            stub: makeStub()
        )
        
        sut.event(event)
        
        XCTAssertNoDiff(reducer.messages.map(\.state), [initialState])
        XCTAssertNoDiff(reducer.messages.map(\.event), [event])
    }
    
    func test_event_shouldNotCallEffectHandlerOnNilEffect() {
        
        let effect: Effect? = nil
        let (sut, _, effectHandler) = makeSUT(
            stub: makeStub(effect)
        )
        
        sut.event(.resetValue)
        
        XCTAssertNoDiff(effectHandler.callCount, 0)
    }
    
    func test_event_shouldCallEffectHandlerOnNonNilEffect() {
        
        let effect: Effect = .load
        let (sut, _, effectHandler) = makeSUT(
            stub: makeStub(effect)
        )
        
        sut.event(.resetValue)
        
        XCTAssertNoDiff(effectHandler.messages.map(\.effect), [effect])
    }
    
    func test_event_shouldCallReducerTwiceOnEffect() {
        
        let (sut, reducer, effectHandler) = makeSUT(
            initialState: makeState(),
            stub: makeStub(.load), makeStub()
        )
        
        sut.event(.resetValue)
        let value = UUID().uuidString
        effectHandler.complete(with: .changeValueTo(value))
        
        XCTAssertNoDiff(reducer.callCount, 2)
    }
    
    func test_event_shouldReducerWithGivenStateAndEvent() {
        
        let initialState = makeState()
        let first = makeStub(.load)
        let last = makeStub()
        let (sut, reducer, effectHandler) = makeSUT(
            initialState: initialState,
            stub: first, last
        )
        
        sut.event(.resetValue)
        let value = UUID().uuidString
        effectHandler.complete(with: .changeValueTo(value))
        
        XCTAssertNoDiff(reducer.messages.map(\.state), [
            initialState,
            first.0
        ])
        XCTAssertNoDiff(reducer.messages.map(\.event), [
            .resetValue,
            .changeValueTo(value)
        ])
    }
    
    func test_event_shouldDeliverStateValues() {
        
        let initialState = makeState()
        let first = makeStub(.load)
        let last = makeStub()
        let (sut, _, effectHandler) = makeSUT(
            initialState: initialState,
            stub: first, last
        )
        let stateSpy = ValueSpy(sut.$state)
        
        sut.event(.resetValue)
        let value = UUID().uuidString
        effectHandler.complete(with: .changeValueTo(value))
        
        XCTAssertNoDiff(stateSpy.values, [initialState, first.0, last.0])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private func makeSUT(
        initialState: State = makeState(),
        stub: (State, Effect?)...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        reducer: ReduceSpy,
        effectHandler: EffectHandlerSpy
    ) {
        
        let reducer = ReduceSpy(stub: stub)
        let effectHandler = EffectHandlerSpy()
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        
        return (sut, reducer, effectHandler)
    }
    
    private final class ReduceSpy {
        
        private var stub: [(State, Effect?)]
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        init(stub: [(State, Effect?)]) {
            
            self.stub = stub
        }
        
        func reduce(
            _ state: State,
            _ event: Event
        ) -> (State, Effect?) {
            
            messages.append((state, event))
            let first = stub.removeFirst()
            
            return first
        }
        
        typealias Message = (state: State, event: Event)
    }
    
    private final class EffectHandlerSpy {
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func handleEffect(
            _ effect: Effect,
            _ dispatch: @escaping Dispatch
        ) {
            messages.append((effect, dispatch))
        }
        
        func complete(
            with event: Event,
            at index: Int = 0
        ) {
            messages[index].dispatch(event)
        }
        
        typealias Dispatch = (Event) -> Void
        typealias Message = (effect: Effect, dispatch: Dispatch)
    }
}

private struct State: Equatable {
    
    let value: String
}

private enum Event: Equatable {
    
    case changeValueTo(String)
    case resetValue
}

private enum Effect: Equatable {
    
    case load
}

private func makeState(
    value: String = UUID().uuidString
) -> State {
    
    .init(value: value)
}

private func makeStub(
    _ effect: Effect? = nil
) -> (State, Effect?) {
    
    (makeState(), effect)
}
