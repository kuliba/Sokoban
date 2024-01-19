//
//  CountdownComposerTests.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Combine
import RxViewModel

// MARK: - State, Event, Effect

enum CountdownState: Equatable {
    
    case completed
    case running(remaining: Int)
}

enum CountdownEvent: Equatable {
    
    case prepare
    case tick
}

enum CountdownEffect: Equatable {
    
    case initiate
}

// MARK: - CountdownEffectHandler

final class CountdownEffectHandler {
    
    private let initiate: Initiate
    
    init(initiate: @escaping Initiate) {
        
        self.initiate = initiate
    }
}

extension CountdownEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension CountdownEffectHandler {
    
    typealias InitiateResult = Result<Void, CountdownFailure>
    typealias InitiateCompletion = (InitiateResult) -> Void
    typealias Initiate = (@escaping InitiateCompletion) -> Void
}

extension CountdownEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = CountdownState
    typealias Event = CountdownEvent
    typealias Effect = CountdownEffect
}

// MARK: - CountdownReducer

final class CountdownReducer {
    
}

extension CountdownReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .tick:
            switch state {
            case .completed:
                break
                
            case let .running(remaining: remaining):
                if remaining > 0 {
                    state = .running(remaining: remaining - 1)
                } else {
                    state = .completed
                }
            }
            
        case .prepare:
            switch state {
            case .completed:
                effect = .initiate
                
            case .running:
                break
            }
        }
        
        return (state, effect)
    }
}

extension CountdownReducer {
    
    typealias State = CountdownState
    typealias Event = CountdownEvent
    typealias Effect = CountdownEffect
}

// MARK: - CountdownViewModel

typealias CountdownViewModel = RxViewModel<CountdownState, CountdownEvent, CountdownEffect>

// MARK: - CountdownComposer

final class CountdownComposer {
    
    private let activate: Activate
    private let timer: TimerProtocol
    private let scheduler: AnySchedulerOfDispatchQueue
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        activate: @escaping Activate,
        timer: TimerProtocol = RealTimer(),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.activate = activate
        self.timer = timer
        self.scheduler = scheduler
    }
}

extension CountdownComposer {
    
    func makeViewModel(duration: Int = 60) -> CountdownViewModel {
        
        let reducer = CountdownReducer()
        let effectHandler = CountdownEffectHandler(initiate: activate)
        
        let viewModel = CountdownViewModel(
            initialState: .running(remaining: duration),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
        
        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .completed:
                    self?.timer.stop()
                    
                case .running(remaining: duration):
                    self?.timer.start(
                        every: 1,
                        onRun: { [weak viewModel] in viewModel?.event(.tick) }
                    )
                    
                case .running(remaining: _):
                    break
                }
            }
            .store(in: &cancellables)
        
        return viewModel
    }
}

extension CountdownComposer {
    
    typealias ActivateResult = Result<Void, CountdownFailure>
    typealias ActivateCompletion = (ActivateResult) -> Void
    typealias Activate = (@escaping ActivateCompletion) -> Void
}

import XCTest

final class CountdownReducerTests: XCTestCase {
    
    // MARK: - prepare
    
    func test_prepare_shouldNotChangeCompletedState() {
        
        let state = completed()
        let sut = makeSUT()
        
        assert(sut, state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldDeliverInitiateEffectOnCompletedState() {
        
        let state = completed()
        let sut = makeSUT()
        
        assert(sut, state, .prepare, effect: .initiate)
    }
    
    func test_prepare_shouldNotChangeRunningState() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldNotDeliverEffectOnRunningState() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, .prepare, effect: nil)
    }
    
    func test_prepare_shouldNotChangeRunningState_one() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldNotDeliverEffectOnRunningState_one() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, .prepare, effect: nil)
    }
    
    func test_prepare_shouldNotChangeRunningState_zero() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldNotDeliverEffectOnRunningState_zero() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, .prepare, effect: nil)
    }
    
    // MARK: - tick
    
    func test_tick_shouldNotChangeCompletedState() {
        
        let state = completed()
        let sut = makeSUT()
        
        assert(sut, state, .tick, reducedTo: state)
    }
    
    func test_tick_shouldNotDeliverEffectOnCompletedState() {
        
        let state = completed()
        let sut = makeSUT()
        
        assert(sut, state, .tick, effect: nil)
    }
    
    func test_tick_shouldDecreaseRemainingOnRunningState() {
        
        let sut = makeSUT()
        
        assert(sut, running(5), .tick, reducedTo: running(4))
    }
    
    func test_tick_shouldNotDeliverEffectOnRunningState() {
        
        let sut = makeSUT()
        
        assert(sut, running(5), .tick, effect: nil)
    }
    
    func test_tick_shouldDecreaseRemainingOnRunningState_one() {
        
        let sut = makeSUT()
        
        assert(sut, running(1), .tick, reducedTo: running(0))
    }
    
    func test_tick_shouldNotDeliverEffectOnRunningState_one() {
        
        let sut = makeSUT()
        
        assert(sut, running(1), .tick, effect: nil)
    }
    
    func test_tick_shouldChangeStateToCompletedOnRunningState_zero() {
        
        let sut = makeSUT()
        
        assert(sut, running(0), .tick, reducedTo: .completed)
    }
    
    func test_tick_shouldNotDeliverEffectOnRunningState_zero() {
        
        let sut = makeSUT()
        
        assert(sut, running(0), .tick, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CountdownReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func completed() -> State {
        
        .completed
    }
    
    private func running(_ remaining: Int) -> State {
        
        .running(remaining: remaining)
    }
    
    private func assert(
        _ sut: SUT,
        _ currentState: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (receivedState, _) = sut.reduce(currentState, event)
        
        XCTAssertNoDiff(
            receivedState, 
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        _ sut: SUT,
        _ currentState: State,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (_, receivedEffect) = sut.reduce(currentState, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}

//final class CountdownComposerTests: XCTestCase {
//
//    // MARK: - Helpers
//
//    private typealias SUT = CountdownComposer
//
//    private func makeSUT(
//        file: StaticString = #file,
//        line: UInt = #line
//    ) -> SUT {
//
//        let sut = SUT()
//
//        trackForMemoryLeaks(sut, file: file, line: line)
//
//        return sut
//    }
//}
