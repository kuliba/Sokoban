//
//  TickViewModelTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Combine

protocol TimerProtocol {
    
    func start(
        every interval: TimeInterval,
        onRun: @escaping () -> Void
    )
    func stop()
}

class RealTimer: TimerProtocol {
    
    private var timer: AnyCancellable?
    
    func start(
        every interval: TimeInterval,
        onRun: @escaping () -> Void
    ) {
        
        timer = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in onRun() })
    }
    
    func stop() {
        
        timer?.cancel()
        timer = nil
    }
}

final class TickViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private let timer: TimerProtocol
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    init(
        initialState: State,
        timer: TimerProtocol,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.timer = timer
        self.reduce = reduce
        self.handleEffect = handleEffect
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension TickViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        switch state {
        case .running:
            timer.start(every: 1) { [weak self] in self?.event(.tick) }
            
        case .idle:
            timer.stop()
        }
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

extension TickViewModel {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}


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
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        let stateSpy = StateSpy(sut.$state)

        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, timerSpy, reducer, effectHandler, stateSpy)
    }
    
    private final class TimerSpy: TimerProtocol {
        
        private var completions = [Completion]()
        
        var callCount: Int { completions.count }
        
        func start(
            every interval: TimeInterval,
            onRun completion: @escaping Completion
        ) {
            completions.append(completion)
        }
        
        func stop() {}
        
        func complete(
            at index: Int = 0
        ) {
            completions[index]()
        }
        
        typealias Completion = () -> Void
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
