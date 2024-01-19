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
    case failure(CountdownFailure)
    case running(remaining: Int)
}

enum CountdownEvent: Equatable {
    
    case failure(CountdownFailure)
    case prepare
    case start
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
        switch effect {
        case .initiate:
            initiate(dispatch)
        }
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

private extension CountdownEffectHandler {
    
    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        initiate { result in
        
            switch result {
            case let .failure(countdownFailure):
                dispatch(.failure(countdownFailure))
                
            case .success(()):
                dispatch(.start)
            }
        }
    }
}

// MARK: - CountdownReducer

final class CountdownReducer {
    
    private let duration: Int
    
    init(duration: Int) {
     
        self.duration = duration
    }
}

extension CountdownReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .failure(countdownFailure):
            switch state {
            case .completed:
                state = .failure(countdownFailure)
                
            case .failure(_):
                fatalError()
                
            case .running:
                break
            }
            
        case .prepare:
            switch state {
            case .completed:
                effect = .initiate
                
            case .failure, .running:
                break
            }

        case .start:
            switch state {
            case .completed:
                state = .running(remaining: duration)
                
            case .failure:
                fatalError()
                
            case .running:
                break
            }

        case .tick:
            switch state {
            case .completed:
                break
                
            case .failure:
                break
                
            case let .running(remaining: remaining):
                if remaining > 0 {
                    state = .running(remaining: remaining - 1)
                } else {
                    state = .completed
                }
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
        
        let reducer = CountdownReducer(duration: duration)
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
                case .failure, .completed:
                    self?.timer.stop()
                    
                case .running(remaining: duration):
                    self?.timer.start(
                        every: 1,
                        onRun: { [weak viewModel] in viewModel?.event(.tick) }
                    )
                    
                case .running:
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
    
    // MARK: - failure: connectivityError
    
    func test_failure_shouldChangeStateToFailureOnCompletedState_connectivity() {
        
        let sut = makeSUT()
        
        assert(sut, completed(), connectivity(), reducedTo: connectivity())
    }
    
    func test_failure_shouldNotDeliverEffectOnCompletedState_connectivity() {
        
        let sut = makeSUT()
        
        assert(sut, completed(), connectivity(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_connectivity() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, connectivity(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_connectivity() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, connectivity(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_one_connectivity() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, connectivity(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_one_connectivity() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, connectivity(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_zero_connectivity() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, connectivity(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_zero_connectivity() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, connectivity(), effect: nil)
    }

    // MARK: - failure: serverError
    
    func test_failure_shouldChangeStateToFailureOnCompletedState_serverError() {
        
        let message = anyMessage()
        let sut = makeSUT()
        
        assert(sut, completed(), serverError(message), reducedTo: serverError(message))
    }
    
    func test_failure_shouldNotDeliverEffectOnCompletedState_serverError() {
        
        let sut = makeSUT()
        
        assert(sut, completed(), serverError(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_serverError() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, serverError(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_serverError() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, serverError(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_one_serverError() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, serverError(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_one_serverError() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, serverError(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_zero_serverError() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, serverError(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_zero_serverError() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, serverError(), effect: nil)
    }

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
    
    // MARK: - start
    
    func test_start_shouldChangeStateToRunningOnCompletedState() {
        
        let sut = makeSUT(duration: 77)
        
        assert(sut, completed(), .start, reducedTo: running(77))
    }
    
    func test_start_shouldNotDeliverEffectOnCompletedState() {
        
        let state = completed()
        let sut = makeSUT()
        
        assert(sut, state, .start, effect: nil)
    }
    
    func test_start_shouldNotChangeRunningState() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, .start, reducedTo: state)
    }
    
    func test_start_shouldNotDeliverEffectOnRunningState() {
        
        let state = running(5)
        let sut = makeSUT()
        
        assert(sut, state, .start, effect: nil)
    }
    
    func test_start_shouldNotChangeRunningState_one() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, .start, reducedTo: state)
    }
    
    func test_start_shouldNotDeliverEffectOnRunningState_one() {
        
        let state = running(1)
        let sut = makeSUT()
        
        assert(sut, state, .start, effect: nil)
    }
    
    func test_start_shouldNotChangeRunningState_zero() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, .start, reducedTo: state)
    }
    
    func test_start_shouldNotDeliverEffectOnRunningState_zero() {
        
        let state = running(0)
        let sut = makeSUT()
        
        assert(sut, state, .start, effect: nil)
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
        duration: Int = 55,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(duration: duration)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func connectivity() -> Event {
        
        .failure(.connectivityError)
    }
    
    private func connectivity() -> State {
        
        .failure(.connectivityError)
    }
    
    private func completed() -> State {
        
        .completed
    }
    
    private func running(
        _ remaining: Int
    ) -> State {
        
        .running(remaining: remaining)
    }
    
    private func serverError(
        _ message: String = anyMessage()
    ) -> Event {
        
        .failure(.serverError(message))
    }
    
    private func serverError(
        _ message: String = anyMessage()
    ) -> State {
        
        .failure(.serverError(message))
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

// MARK: - CountdownEffectHandlerTests

final class CountdownEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldDeliverStartEventOnSuccess() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .start, on: {
            
            spy.complete(with: .success(()))
        })
    }
    
    func test_initiate_shouldDeliverConnectivityErrorFailureEventOnConnectivityFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: connectivity(), on: {
            
            spy.complete(with: connectivity())
        })
    }
    
    func test_initiate_shouldDeliverServerErrorFailureEventOnServerFailure() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: serverError(message), on: {
            
            spy.complete(with: serverError(message))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CountdownEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias InitiateSpy = Spy<Void, SUT.InitiateResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiateSpy: InitiateSpy
    ) {
        let initiateSpy = InitiateSpy()
        let sut = SUT(initiate: initiateSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(initiateSpy, file: file, line: line)
        
        return (sut, initiateSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) { receivedEvent in
            
            XCTAssertNoDiff(
                receivedEvent,
                expectedEvent,
                "\nExpected \(expectedEvent), but got \(receivedEvent) instead.",
                file: file, line: line
            )
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

private func connectivity(
) -> CountdownEvent {
    
    .failure(.connectivityError)
}

private func connectivity(
) -> CountdownEffectHandler.InitiateResult {
    
    .failure(.connectivityError)
}

private func serverError(
    _ message: String = anyMessage()
) -> CountdownEvent {
    
    .failure(.serverError(message))
}

private func serverError(
    _ message: String = anyMessage()
) -> CountdownEffectHandler.InitiateResult {
    
    .failure(.serverError(message))
}

// MARK: - CountdownComposerTests

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
