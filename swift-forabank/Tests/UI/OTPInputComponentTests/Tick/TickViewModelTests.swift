//
//  TickViewModelTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import XCTest

final class TickViewModelTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, timerSpy, reducer, effectHandler, _) = makeSUT()
        
        XCTAssertEqual(timerSpy.callCount, 0)
        XCTAssertEqual(reducer.callCount, 0)
        XCTAssertEqual(effectHandler.callCount, 0)
    }
    
    func test_init_shouldSetInitialValue() {
        
        let initialState = State.running(remaining: 123)
        let (_,_,_,_, stateSpy) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(stateSpy.values, [initialState])
    }
    
    func test_event_shouldCallReducerWithGivenStateAndEvent() {
        
        let initialState: State = .running(remaining: 123)
        let event: Event = .failure(.connectivityError)
        let (sut, _, reducer, _,_) = makeSUT(
            initialState: initialState,
            stub: (.idle(.connectivityError), nil)
        )
        
        sut.event(event)
        
        XCTAssertNoDiff(reducer.messages.map(\.state), [initialState])
        XCTAssertNoDiff(reducer.messages.map(\.event), [event])
    }
    
    func test_event_shouldStopTimerOnIdle() {
        
        let (sut, timer, _,_,_) = makeSUT(
            stub: (.idle(nil), nil)
        )
        
        sut.event(.appear)
        
        XCTAssertNoDiff(timer.messages, [.stop])
    }
    
    func test_event_shouldCallTimerOnRunning() {
        
        let (sut, timer, _,_,_) = makeSUT(
            stub: (.running(remaining: 123), nil)
        )
        
        sut.event(.appear)
        
        XCTAssertNoDiff(timer.messages, [.start])
    }
    
    func test_event_shouldTimerShouldEmitTickOnRunning() {
        
        let (sut, timer, reducer, _,_) = makeSUT(
            stub: (.running(remaining: 123), nil),
            (.running(remaining: 12), nil)
        )
        
        sut.event(.appear)
        timer.complete()
        
        XCTAssertNoDiff(reducer.messages.map(\.event), [.appear, .tick])
        XCTAssertNoDiff(reducer.messages.map(\.state), [idle(), running(123)])
    }
    
    func test_event_shouldNotCallEffectHandlerOnNilEffect() {
        
        let effect: Effect? = nil
        let (sut, _, _, effectHandler,_) = makeSUT(
            stub: (.idle(.connectivityError), effect)
        )
        
        sut.event(.appear)
        
        XCTAssertNoDiff(effectHandler.callCount, 0)
    }
    
    func test_event_shouldCallEffectHandlerOnNonNilEffect() {
        
        let effect: Effect = .initiate
        let (sut, _, _, effectHandler,_) = makeSUT(
            stub: (.idle(.connectivityError), effect)
        )
        
        sut.event(.appear)
        
        XCTAssertNoDiff(effectHandler.messages.map(\.effect), [effect])
    }
    
    func test_event_shouldDeliverEventCompletedByEffectHandler() {
        
        let (sut, _, reducer, effectHandler,_) = makeSUT(
            stub: (idleConnectivity(), .initiate),
            (running(123), nil)
        )
        
        sut.event(.appear)
        effectHandler.complete(with: .start)
        
        XCTAssertNoDiff(reducer.messages.map(\.event), [.appear, .start])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TickViewModel
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
    
    typealias StateSpy = ValueSpy<State>
    
    private func makeSUT(
        initialState: TickViewModel.State = .idle(nil),
        stub: (State, Effect?)...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        timerSpy: TimerSpy,
        reducer: ReduceSpy,
        effectHandler: EffectHandlerSpy,
        stateSpy: StateSpy
    ) {
        
        let timerSpy = TimerSpy()
        let reducer = ReduceSpy(stub: stub)
        let effectHandler = EffectHandlerSpy()
        let sut = SUT(
            initialState: initialState,
            timer: timerSpy,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, timerSpy, reducer, effectHandler, stateSpy)
    }
    
    private final class TimerSpy: TimerProtocol {
        
        private var completions = [Completion]()
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func start(
            every interval: TimeInterval,
            onRun completion: @escaping Completion
        ) {
            completions.append(completion)
            messages.append(.start)
        }
        
        func stop() {
            
            messages.append(.stop)
        }
        
        func complete(
            at index: Int = 0
        ) {
            completions[index]()
        }
        
        typealias Completion = () -> Void
        enum Message: Equatable {
            
            case start, stop
        }
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
