//
//  TickReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

final class TickReducer {
    
    private let interval: Int
    
    init(interval: Int = 60) {
     
        self.interval = interval
    }
}

extension TickReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch (state.core, event) {
        case (.idle, .appear):
            return (.init(.idle), .initiate)
            
        case (.idle, .start):
            let state = State(.running(remaining: interval))
            return (state, nil)
            
        case let (.idle, .failure(tickFailure)):
            return (.init(.idle, status: .failure(tickFailure)), nil)
            
        case let (.running(remaining), .tick):
            if remaining > 0 {
                let state = State(.running(remaining: remaining - 1))
                return (state, nil)
            } else {
                return (.init(.idle), nil)
            }
            
        case (_, .resetStatus):
            switch state.core {
            case .idle:
                return (.init(.idle), nil)
                
            case let .running(remaining):
                return (.init(.running(remaining: remaining)), nil)
            }
            
        default:
            // fatalError()
            return (state, nil)
        }
    }
}

extension TickReducer {
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}

import XCTest

final class TickReducerTests: XCTestCase {
    
    // MARK: - appear
    
    func test_appear_shouldNotChangeState_idle() {
        
        assert(idle(), .appear, reducedTo: idle())
    }
    
    func test_appear_shouldDeliverEffect_idle() {
        
        assert(idle(), .appear, effect: .initiate)
    }
    
    // MARK: - start
    
    func test_start_shouldSetStateToRunning_idle() {
        
        let sut = makeSUT(interval: 77)
        
        assert(sut: sut, idle(), .start, reducedTo: .init(
            .running(remaining: 77)
        ))
    }
    
    func test_start_shouldNotDeliverEffect_idle() {
        
        assert(idle(), .start, effect: nil)
    }
    
    // MARK: - failure
    
    func test_failure_shouldSetStateToFailure_idle_connectivity() {
        
        assert(idle(), connectivity(), reducedTo: .init(
            .idle,
            status: connectivity()
        ))
    }
    
    func test_failure_shouldNotDeliverEffect_idle_connectivity() {
        
        assert(idle(), connectivity(), effect: nil)
    }
    
    func test_failure_shouldSetStateToFailure_idle_server() {
        
        let message = anyMessage()
        
        assert(idle(), serverError(message), reducedTo: .init(
            .idle,
            status: serverError(message)
        ))
    }
    
    func test_failure_shouldNotDeliverEffect_idle_server() {
        
        let message = anyMessage()
        
        assert(idle(), serverError(message), effect: nil)
    }
    
    func test_tick_shouldLowerRemaining_running() {
        
        assert(.init(.running(remaining: 5)), .tick, reducedTo: .init(.running(remaining: 4)))
    }
    
    func test_tick_shouldNotDeliverEffect_running() {
        
        assert(.init(.running(remaining: 5)), .tick, effect: nil)
    }
    
    func test_tick_shouldLowerRemaining_running_one() {
        
        assert(.init(.running(remaining: 1)), .tick, reducedTo: .init(.running(remaining: 0)))
    }
    
    func test_tick_shouldNotDeliverEffect_running_one() {
        
        assert(.init(.running(remaining: 1)), .tick, effect: nil)
    }
    
    func test_tick_shouldChangeStateToIdleOnRemainingZero_running() {
        
        assert(.init(.running(remaining: 0)), .tick, reducedTo: idle())
    }
    
    func test_tick_shouldNotDeliverEffectOnRemainingZero_running() {
        
        assert(.init(.running(remaining: 0)), .tick, effect: nil)
    }
    
    func test_tick_shouldNotChangeState_idle() {
        
        assert(idle(), .tick, reducedTo: idle())
    }
    
    func test_tick_shouldNotDeliverEffect_idle() {
        
        assert(idle(), .tick, effect: nil)
    }
    
    func test_tick_shouldNotChangeState_idle_failure() {
        
        assert(idleConnectivity(), .tick, reducedTo: idleConnectivity())
    }
    
    func test_tick_shouldNotDeliverEffect_idle_failure() {
        
        assert(idleConnectivity(), .tick, effect: nil)
    }
    
    // MARK: - resetStatus
    
    func test_resetStatus_shouldNotChangeState_idle() {
        
        assert(idle(), .resetStatus, reducedTo: idle())
    }
    
    func test_resetStatus_shouldNotDeliverEffect_idle() {
        
        assert(idle(), .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatus_idle_connectivity() {
        
        assert(idleConnectivity(), .resetStatus, reducedTo: idle())
    }
    
    func test_resetStatus_shouldNotDeliverEffect_idle_connectivity() {
        
        assert(idleConnectivity(), .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatus_running_connectivity() {
        
        assert(runningConnectivity(9), .resetStatus, reducedTo: running(9))
    }
    
    func test_resetStatus_shouldNotDeliverEffect_running_connectivity() {
        
        assert(runningConnectivity(9), .resetStatus, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TickReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        interval: Int = 60,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(interval: interval)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
