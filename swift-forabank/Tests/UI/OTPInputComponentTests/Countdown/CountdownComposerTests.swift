//
//  CountdownComposerTests.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Combine
import RxViewModel

enum CountdownState: Equatable {
    
    case running(remaining: Int)
    case completed
}

enum CountdownEvent: Equatable {
    
    case tick
}

enum CountdownEffect: Equatable {
    
    case initiate
}

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

final class CountdownReducer {
    
}

extension CountdownReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
     
        var state = state
        var effect: Effect?

        return (state, effect)
    }
}

extension CountdownReducer {
    
    typealias State = CountdownState
    typealias Event = CountdownEvent
    typealias Effect = CountdownEffect
}

typealias CountdownViewModel = RxViewModel<CountdownState, CountdownEvent, CountdownEffect>
    
final class CountdownComposer {
    
    private let activate: Activate
    private let timer: TimerProtocol
    private let viewModel: CountdownViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        duration: Int = 60,
        activate: @escaping Activate,
        timer: TimerProtocol = RealTimer(),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.activate = activate
        self.timer = timer
        
        let reducer = CountdownReducer()
        let effectHandler = CountdownEffectHandler(initiate: activate)
        
        self.viewModel = CountdownViewModel(
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
                    self?.timer.start(every: 1, onRun: { [weak self] in
                        
                        self?.viewModel.event(.tick)
                    })
                    
                case .running(remaining: _):
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension CountdownComposer {
    
    typealias ActivateResult = Result<Void, CountdownFailure>
    typealias ActivateCompletion = (ActivateResult) -> Void
    typealias Activate = (@escaping ActivateCompletion) -> Void
}

import XCTest

final class CountdownComposerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = CountdownComposer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
