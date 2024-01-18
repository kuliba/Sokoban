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
        
        var state = state
        var effect: Effect?
        
        switch (state, event) {
        case (.idle(nil), .appear):
            effect = .initiate
            
        case (.idle(nil), .start):
            state = .running(remaining: interval)
            
        case let (.idle(nil), .failure(tickFailure)):
            state = .idle(tickFailure)
            
        case let (.running(remaining), .tick):
            if remaining > 0 {
                state = .running(remaining: remaining - 1)
            } else {
                state = .idle(nil)
            }
            
        case (.idle(.connectivityError), .resetFailure):
            state = .idle(nil)
            
        case (.idle(.serverError), .resetFailure):
            state = .idle(nil)
            
        default:
            // fatalError()
            break
        }
        
        return (state, effect)
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
    
    // MARK: - failure
    
    func test_failure_shouldSetStateToFailure_idle_connectivity() {
        
        assert(idle(), connectivity(), reducedTo: .idle(.connectivityError))
    }
    
    func test_failure_shouldNotDeliverEffect_idle_connectivity() {
        
        assert(idle(), connectivity(), effect: nil)
    }
    
    func test_failure_shouldSetStateToFailure_idle_server() {
        
        let message = anyMessage()
        
        assert(idle(), serverError(message), reducedTo: .idle(.serverError(message)))
    }
    
    func test_failure_shouldNotDeliverEffect_idle_server() {
        
        let message = anyMessage()
        
        assert(idle(), serverError(message), effect: nil)
    }
    
    func test_tick_shouldLowerRemaining_running() {
        
        assert(running(5), .tick, reducedTo: running(4))
    }
    
    func test_tick_shouldNotDeliverEffect_running() {
        
        assert(running(5), .tick, effect: nil)
    }
    
    func test_tick_shouldLowerRemaining_running_one() {
        
        assert(running(1), .tick, reducedTo: running(0))
    }
    
    func test_tick_shouldNotDeliverEffect_running_one() {
        
        assert(running(1), .tick, effect: nil)
    }
    
    func test_tick_shouldChangeStateToIdleOnRemainingZero_running() {
        
        assert(running(0), .tick, reducedTo: idle())
    }
    
    func test_tick_shouldNotDeliverEffectOnRemainingZero_running() {
        
        assert(running(0), .tick, effect: nil)
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
    
    // MARK: - resetFailure
    
    func test_resetFailure_shouldNotChangeState_idle() {
        
        assert(idle(), .resetFailure, reducedTo: idle())
    }
    
    func test_resetFailure_shouldNotDeliverEffect_idle() {
        
        assert(idle(), .resetFailure, effect: nil)
    }
    
    func test_resetFailure_shouldResetStatus_idle_connectivity() {
        
        assert(idleConnectivity(), .resetFailure, reducedTo: idle())
    }
    
    func test_resetFailure_shouldNotDeliverEffect_idle_connectivity() {
        
        assert(idleConnectivity(), .resetFailure, effect: nil)
    }
    
    // MARK: - start
    
    func test_start_shouldSetStateToRunning_idle() {
        
        let sut = makeSUT(interval: 77)
        
        assert(sut: sut, idle(), .start, reducedTo: .running(remaining: 77))
    }
    
    func test_start_shouldNotDeliverEffect_idle() {
        
        assert(idle(), .start, effect: nil)
    }
    
    func test_start_shouldNotChangeState_idle_failure() {
        
        assert(idleConnectivity(), .start, reducedTo: idleConnectivity())
    }
    
    func test_start_shouldNotDeliverEffect_idle_failure() {
        
        assert(idleConnectivity(), .start, effect: nil)
    }
    
    func test_start_shouldNotChangeState_running() {
        
        assert(running(45), .start, reducedTo: running(45))
    }
    
    func test_start_shouldNotDeliverEffect_running() {
        
        assert(running(45), .start, effect: nil)
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
