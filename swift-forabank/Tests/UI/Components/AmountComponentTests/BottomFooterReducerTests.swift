//
//  BottomFooterReducerTests.swift
//  
//
//  Created by Igor Malyarov on 21.06.2024.
//

import AmountComponent
import XCTest

final class BottomFooterReducerTests: XCTestCase {
    
    // MARK: - button events
    
    func test_disable_shouldSetActiveButtonStateToInactive() {
        
        let state = makeState(buttonState: .active)
        
        assertState(.button(.disable), on: state) {
            
            $0.buttonState = .inactive
        }
    }
    
    func test_disable_shouldNotChangeInactiveButtonState() {
        
        let state = makeState(buttonState: .inactive)
        
        assertState(.button(.disable), on: state)
    }
    
    func test_disable_shouldNotChangeTappedButtonState() {
        
        let state = makeState(buttonState: .tapped)
        
        assertState(.button(.disable), on: state)
    }
    
    func test_enable_shouldSetInactiveButtonStateToActive() {
        
        let state = makeState(buttonState: .inactive)
        
        assertState(.button(.enable), on: state) {
            
            $0.buttonState = .active
        }
    }
    
    func test_enable_shouldNotChangeActiveButton() {
        
        let state = makeState(buttonState: .active)
        
        assertState(.button(.enable), on: state)
    }
    
    func test_enable_shouldSetTappedButtonStateToActive() {
        
        let state = makeState(buttonState: .tapped)
        
        assertState(.button(.enable), on: state) {
            
            $0.buttonState = .active
        }
    }

    func test_tap_shouldNotChangeInactiveButtonState() {
        
        let state = makeState(buttonState: .inactive)
        
        assertState(.button(.tap), on: state)
    }
    
    func test_tap_shouldSetActiveButtonStateToTapped() {
        
        let state = makeState(buttonState: .active)
        
        assertState(.button(.tap), on: state) {
            
            $0.buttonState = .tapped
        }
    }
    
    func test_tap_shouldNotChangeTappedButtonState() {
        
        let state = makeState(buttonState: .tapped)
        
        assertState(.button(.tap), on: state)
    }
    
    func test_buttonEvent_shouldNotDeliverEffectOnActiveState() {
        
        let state = makeState(buttonState: .active)
        
        assert(.button(.disable), on: state, effect: nil)
    }
    
    func test_buttonEvent_shouldNotDeliverEffectOnInactiveState() {
        
        let state = makeState(buttonState: .inactive)
        
        assert(.button(.disable), on: state, effect: nil)
    }
    
    func test_buttonEvent_shouldNotDeliverEffectOnATappedState() {
        
        let state = makeState(buttonState: .tapped)
        
        assert(.button(.disable), on: state, effect: nil)
    }
    
    // MARK: - edit
    
    func test_edit_shouldNotSetNegativeAmount() {
        
        let state = makeState(amount: 99)
        
        assertState(.edit(-9), on: state)
    }
    
    func test_edit_shouldSetAmountToGivenOnActiveState() {
        
        let state = makeState(amount: 99)
        
        assertState(.edit(9), on: state) {
            
            $0.amount = 9
        }
    }
    
    func test_edit_shouldNotChangeAmountOnInactiveState() {
        
        let state = makeState(amount: 99, buttonState: .inactive)
        
        assertState(.edit(9), on: state)
    }
    
    func test_edit_shouldNotChangeAmountOnTappedState() {
        
        let state = makeState(amount: 99, buttonState: .tapped)
        
        assertState(.edit(9), on: state)
    }
    
    func test_edit_shouldNotDeliverEffectOnActiveState() {
        
        assert(.edit(99), on: makeState(buttonState: .active), effect: nil)
    }
    
    func test_edit_shouldNotDeliverEffectOnInactiveState() {
        
        assert(.edit(99), on: makeState(buttonState: .inactive), effect: nil)
    }
    
    func test_edit_shouldNotDeliverEffectOnTappedState() {
        
        assert(.edit(99), on: makeState(buttonState: .tapped), effect: nil)
    }
    
    // MARK: - style
    
    func test_style_shouldNotChangeStyleToAmountOnAmountStyle() {
        
        let state = makeState(style: .amount)
        
        assertState(.style(.amount), on: state)
    }
    
    func test_style_shouldSetStyleToAmountOnButtonStyle() {
        
        let state = makeState(style: .button)
        
        assertState(.style(.amount), on: state) {
            
            $0.style = .amount
        }
    }
    
    func test_style_shouldNotChangeStyleToButtonOnButtonStyle() {
        
        let state = makeState(style: .button)
        
        assertState(.style(.button), on: state)
    }
    
    func test_style_shouldSetStyleToButtonOnAmountStyle() {
        
        let state = makeState(style: .amount)
        
        assertState(.style(.button), on: state) {
            
            $0.style = .button
        }
    }
    
    func test_style_shouldNotDeliverEffectOnTappedState() {
        
        assert(.style(.amount), on: makeState(style: .button), effect: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = BottomFooterReducer
    
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
    
    private func makeState(
        amount: Decimal = .init(Double.random(in: 1...100)),
        buttonState: State.ButtonState = .active,
        style: State.Style = .amount
    ) -> State {
        
        return .init(
            amount: amount,
            buttonState: buttonState,
            style: style
        )
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
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
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
