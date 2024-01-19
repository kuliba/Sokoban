//
//  OTPInputReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import OTPInputComponent
import XCTest

final class OTPInputReducerTests: XCTestCase {
    
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
        
        assert(sut: sut, state, .edit(digits), reducedTo: makeState("98765", isOTPComplete: true))
    }
    
    func test_edit_shouldChangeToCompleteStateOnReachingLimit() {
        
        let digits = "12345"
        let state = makeState("1234")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(digits), reducedTo: makeState(digits, isOTPComplete: true))
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
        
        assert(sut: sut, state, .edit(digits), reducedTo: makeState(digits, isOTPComplete: true))
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
    
    private func emptyState() -> State {
        
        makeState("", isOTPComplete: false)
    }
    
    private func makeState(
        _ text: String,
        isOTPComplete: Bool = false
    ) -> State {
        
        .init(text: text, isOTPComplete: isOTPComplete)
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
