//
//  CountdownReducerTests.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import XCTest

final class CountdownReducerTests: XCTestCase {
    
    // MARK: - failure: connectivityError
    
    func test_failure_shouldChangeStateToFailureOnCompletedState_connectivity() {
        
        assert(completed(), connectivity(), reducedTo: connectivity())
    }
    
    func test_failure_shouldNotDeliverEffectOnCompletedState_connectivity() {
        
        assert(completed(), connectivity(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_connectivity() {
        
        let state = running(5)
        
        assert(state, connectivity(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_connectivity() {
        
        let state = running(5)
        
        assert(state, connectivity(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_one_connectivity() {
        
        let state = running(1)
        
        assert(state, connectivity(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_one_connectivity() {
        
        let state = running(1)
        
        assert(state, connectivity(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_zero_connectivity() {
        
        let state = running(0)
        
        assert(state, connectivity(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_zero_connectivity() {
        
        let state = running(0)
        
        assert(state, connectivity(), effect: nil)
    }
    
    // MARK: - failure: serverError
    
    func test_failure_shouldChangeStateToFailureOnCompletedState_serverError() {
        
        let message = anyMessage()
        
        assert(completed(), serverError(message), reducedTo: serverError(message))
    }
    
    func test_failure_shouldNotDeliverEffectOnCompletedState_serverError() {
        
        assert(completed(), serverError(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_serverError() {
        
        let state = running(5)
        
        assert(state, serverError(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_serverError() {
        
        let state = running(5)
        
        assert(state, serverError(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_one_serverError() {
        
        let state = running(1)
        
        assert(state, serverError(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_one_serverError() {
        
        let state = running(1)
        
        assert(state, serverError(), effect: nil)
    }
    
    func test_failure_shouldNotChangeRunningState_zero_serverError() {
        
        let state = running(0)
        
        assert(state, serverError(), reducedTo: state)
    }
    
    func test_failure_shouldNotDeliverEffectOnRunningState_zero_serverError() {
        
        let state = running(0)
        
        assert(state, serverError(), effect: nil)
    }
    
    // MARK: - prepare
    
    func test_prepare_shouldNotChangeCompletedState() {
        
        let state = completed()
        
        assert(state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldDeliverInitiateEffectOnCompletedState() {
        
        let state = completed()
        
        assert(state, .prepare, effect: .initiate)
    }
    
    func test_prepare_shouldNotChangeRunningState() {
        
        let state = running(5)
        
        assert(state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldNotDeliverEffectOnRunningState() {
        
        let state = running(5)
        
        assert(state, .prepare, effect: nil)
    }
    
    func test_prepare_shouldNotChangeRunningState_one() {
        
        let state = running(1)
        
        assert(state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldNotDeliverEffectOnRunningState_one() {
        
        let state = running(1)
        
        assert(state, .prepare, effect: nil)
    }
    
    func test_prepare_shouldNotChangeRunningState_zero() {
        
        let state = running(0)
        
        assert(state, .prepare, reducedTo: state)
    }
    
    func test_prepare_shouldNotDeliverEffectOnRunningState_zero() {
        
        let state = running(0)
        
        assert(state, .prepare, effect: nil)
    }
    
    // MARK: - start
    
    func test_start_shouldChangeStateToStartingOnCompletedState() {
        
        let duration = 77
        let sut = makeSUT(duration: duration)
        
        assert(sut: sut, completed(), .start, reducedTo: .starting(duration: duration))
    }
    
    func test_start_shouldNotDeliverEffectOnCompletedState() {
        
        let state = completed()
        
        assert(state, .start, effect: nil)
    }
    
    func test_start_shouldNotChangeRunningState() {
        
        let state = running(5)
        
        assert(state, .start, reducedTo: state)
    }
    
    func test_start_shouldNotDeliverEffectOnRunningState() {
        
        let state = running(5)
        
        assert(state, .start, effect: nil)
    }
    
    func test_start_shouldNotChangeRunningState_one() {
        
        let state = running(1)
        
        assert(state, .start, reducedTo: state)
    }
    
    func test_start_shouldNotDeliverEffectOnRunningState_one() {
        
        let state = running(1)
        
        assert(state, .start, effect: nil)
    }
    
    func test_start_shouldNotChangeRunningState_zero() {
        
        let state = running(0)
        
        assert(state, .start, reducedTo: state)
    }
    
    func test_start_shouldNotDeliverEffectOnRunningState_zero() {
        
        let state = running(0)
        
        assert(state, .start, effect: nil)
    }
    
    // MARK: - tick
    
    func test_tick_shouldNotChangeCompletedState() {
        
        let state = completed()
        
        assert(state, .tick, reducedTo: state)
    }
    
    func test_tick_shouldNotDeliverEffectOnCompletedState() {
        
        let state = completed()
        
        assert(state, .tick, effect: nil)
    }
    
    func test_tick_shouldDecreaseRemainingOnRunningState() {
        
        assert(running(5), .tick, reducedTo: running(4))
    }
    
    func test_tick_shouldNotDeliverEffectOnRunningState() {
        
        assert(running(5), .tick, effect: nil)
    }
    
    func test_tick_shouldDecreaseRemainingOnRunningState_one() {
        
        assert(running(1), .tick, reducedTo: running(0))
    }
    
    func test_tick_shouldNotDeliverEffectOnRunningState_one() {
        
        assert(running(1), .tick, effect: nil)
    }
    
    func test_tick_shouldChangeStateToCompletedOnRunningState_zero() {
        
        assert(running(0), .tick, reducedTo: .completed)
    }
    
    func test_tick_shouldNotDeliverEffectOnRunningState_zero() {
        
        assert(running(0), .tick, effect: nil)
    }
    
    func test_tick_shouldChangeStateToRunningWithRemainingEqualToDurationMinusOneOnStartingState() {
        
        let duration = 55
        let sut = makeSUT(duration: duration)
        
        assert(sut: sut, .starting(duration: duration), .tick, reducedTo: .running(remaining: duration - 1))
    }
    
    func test_tick_shouldNotDeliverEffectOnOnStartingState() {
        
        assert(.starting(duration: 55), .tick, effect: nil)
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
        sut: SUT? = nil,
        _ currentState: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        let (receivedState, _) = sut.reduce(currentState, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ currentState: State,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        let (_, receivedEffect) = sut.reduce(currentState, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
