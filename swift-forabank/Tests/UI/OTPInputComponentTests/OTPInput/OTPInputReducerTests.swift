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
    
    func test_edit_shouldChangeStateOnDigitInput() {
        
        let nonDigit = "8766"
        let state = makeState("123")
        
        assert(state, .edit(nonDigit), reducedTo: makeState("8766"))
    }
    
    func test_edit_shouldNotDeliverEffectOnDigitInputLessThanLimit() {
        
        let nonDigit = "8766"
        let state = makeState("123")
        
        assert(state, .edit(nonDigit), effect: nil)
    }
    
    func test_edit_shouldLimitInput() {
        
        let nonDigit = "987654321"
        let state = makeState("123")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(nonDigit), reducedTo: makeState("98765"))
    }
    
    func test_edit_shouldNotDeliverEffectOnReachingLimit() {
        
        let nonDigit = "12345"
        let state = makeState("1234")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(nonDigit), effect: nil)
    }
    
    func test_edit_shouldNotDeliverEffectOnLimit() {
        
        let nonDigit = "98765"
        let state = makeState("12345")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(nonDigit), effect: nil)
    }
    
    func test_edit_shouldNotDeliverEffectAfterLimit() {
        
        let nonDigit = "987654"
        let state = makeState("12345")
        let sut = makeSUT(length: 5)
        
        assert(sut: sut, state, .edit(nonDigit), effect: nil)
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
        
        makeState("")
    }
    
    private func makeState(_ text: String) -> State {
        
        .init(text: text)
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
