//
//  OTPInputReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import OTPInputComponent
import XCTest

final class OTPInputReducerTests: XCTestCase {
    
    // MARK: - confirmOTP
    
    func test_confirmOTP_shouldNotChangeStateOnIncompleteInput() {
        
        let state = incomplete()
        
        assert(state, .confirmOTP, reducedTo: state)
    }
    
    func test_confirmOTP_shouldNotDeliverEffectOnIncompleteInput() {
        
        let state = incomplete()
        
        assert(state, .confirmOTP, effect: nil)
    }
    
    func test_confirmOTP_shouldSetInflightStateOnCompleteInput() {
        
        let state = complete()
        
        assert(state, .confirmOTP, reducedTo: state.updated(
            status: .inflight
        ))
    }
    
    func test_confirmOTP_shouldDeliverEffectOnCompleteInput() {
        
        let state = complete("876543")
        
        assert(state, .confirmOTP, effect: .submitOTP("876543"))
    }
    
    // MARK: - edit
    
    func test_edit_shouldNotChangeEmptyStateOnNonDigitInput() {
        
        let nonDigit = "asB$%^"
        let state = emptyState()
        
        assert(state, .edit(nonDigit), reducedTo: state)
    }
    
    func test_edit_shouldNotDeliverEffectOnNonDigitInputInEmptyState() {
        
        let nonDigit = "asB$%^"
        let state = emptyState()
        
        assert(state, .edit(nonDigit), effect: nil)
    }
    
    func test_edit_shouldChangeStateToEmptyOnNonDigitInput() {
        
        let nonDigit = "asB$%^"
        let state = makeState("123")
        
        assert(state, .edit(nonDigit), reducedTo: emptyState())
    }
    
    func test_edit_shouldNotDeliverEffectOnNonDigitInput() {
        
        let nonDigit = "asB$%^"
        let state = makeState("123")
        
        assert(state, .edit(nonDigit), effect: nil)
    }
    
    func test_edit_shouldChangeEmptyStateOnDigitInput() {
        
        let digits = "8766"
        let state = emptyState()
        
        assert(state, .edit(digits), reducedTo: makeState(digits))
    }
    
    func test_edit_shouldNotDeliverEffectOnDigitInputInEmptyState() {
        
        let digits = "8766"
        let state = emptyState()
        
        assert(state, .edit(digits), reducedTo: makeState(digits))
    }
    
    func test_edit_shouldChangeStateOnDigitInput() {
        
        let digits = "8766"
        let state = makeState("123")
        
        assert(state, .edit(digits), reducedTo: makeState(digits))
    }
    
    func test_edit_shouldNotDeliverEffectOnDigitInputLessThanLimit() {
        
        let digits = "8766"
        let state = makeState("123")
        
        assert(state, .edit(digits), effect: nil)
    }
    
    func test_edit_shouldLimitInput() {
        
        let digits = "987654321"
        let state = makeState("123")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), reducedTo: makeState("98765", isInputComplete: true))
    }
    
    func test_edit_shouldChangeToCompleteStateOnReachingLimit() {
        
        let digits = "12345"
        let state = makeState("1234")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), reducedTo: makeState(digits, isInputComplete: true))
    }
    
    func test_edit_shouldNotDeliverEffectOnReachingLimit() {
        
        let digits = "12345"
        let state = makeState("1234")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), effect: nil)
    }
    
    func test_edit_shouldChangeStateOnLimit() {
        
        let digits = "98765"
        let state = makeState("12345")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), reducedTo: makeState(digits, isInputComplete: true))
    }
    
    func test_edit_shouldNotDeliverEffectOnLimit() {
        
        let digits = "98765"
        let state = makeState("12345")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), effect: nil)
    }
    
    func test_edit_shouldNotDeliverEffectAfterLimit() {
        
        let digits = "987654"
        let state = makeState("12345")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), effect: nil)
    }
    
    // MARK: - failure connectivityError
    
    func test_failure_connectivityError_shouldNotChangeIncompleteState() {
        
        let state = incomplete()
        
        assert(state, connectivity(), reducedTo: state)
    }
    
    func test_failure_connectivityError_shouldNotDeliverEffectOnIncompleteState() {
        
        let state = incomplete()
        
        assert(state, connectivity(), effect: nil)
    }
    
    func test_failure_connectivityError_shouldSetStatusToConnectivityErrorFailureOnCompleteState() {
        
        let state = complete()
        
        assert(state, connectivity(), reducedTo: state.updated(
            status: .failure(.connectivityError)
        ))
    }
    
    func test_failure_connectivityError_shouldNotDeliverEffectOnConnectivityErrorFailureInCompleteState() {
        
        let state = complete()
        
        assert(state, connectivity(), effect: nil)
    }
    
    // MARK: - failure serverError
    
    func test_failure_serverError_shouldNotChangeIncompleteState() {
        
        let message = anyMessage()
        let state = incomplete()
        
        assert(state, serverError(message), reducedTo: state)
    }
    
    func test_failure_serverError_shouldNotDeliverEffectOnIncompleteState() {
        
        let message = anyMessage()
        let state = incomplete()
        
        assert(state, serverError(message), effect: nil)
    }
    
    func test_failure_serverError_shouldSetStatusToServerErrorFailureOnCompleteState() {
        
        let message = anyMessage()
        let state = complete()
        
        assert(state, serverError(message), reducedTo: state.updated(
            status: .failure(.serverError(message))
        ))
    }
    
    func test_failure_serverError_shouldNotDeliverEffectOnServerErrorFailureInCompleteState() {
        
        let message = anyMessage()
        let state = complete()
        
        assert(state, serverError(message), effect: nil)
    }
    
    // MARK: - otpValidated
    
    func test_otpValidated_shouldNotChangeIncompleteState() {
        
        let state = incomplete()
        
        assert(state, .otpValidated, reducedTo: state)
    }
    
    func test_otpValidated_shouldNotDeliverEffectOnIncompleteState() {
        
        let state = incomplete()
        
        assert(state, .otpValidated, effect: nil)
    }
    
    func test_otpValidated_shouldSetStatusToValidatedCompleteState() {
        
        let state = complete()
        
        assert(state, .otpValidated, reducedTo: state.updated(
            status: .validOTP
        ))
    }
    
    func test_otpValidated_shouldNotDeliverEffectOnCompleteState() {
        
        let state = complete()
        
        assert(state, .otpValidated, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        length: Int = 6,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(length: length)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func connectivity() -> Event {
        
        .failure(.connectivityError)
    }
    
    private func serverError(
        _ message: String = anyMessage()
    ) -> Event {
        
        .failure(.serverError(message))
    }
    
    private func emptyState() -> State {
        
        makeState("", isInputComplete: false)
    }
    
    private func complete(
        _ text: String = "76543"
    ) -> State {
        
        makeState(text, isInputComplete: true)
    }
    
    private func incomplete(
        _ text: String = "76543"
    ) -> State {
        
        makeState(text, isInputComplete: false)
    }
    
    private func makeState(
        _ text: String,
        isInputComplete: Bool = false,
        status: OTPInputState.Status? = nil
    ) -> State {
        
        .init(text: text, isInputComplete: isInputComplete, status: status)
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
