//
//  FooterViewModelTests.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import AmountComponent
import TextFieldDomain
import TextFieldComponent
import XCTest

final class FooterViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetInitialValue() {
        
        let initial = makeState(amount: 987)
        let (_,_, spy) = makeSUT(initialState: initial)
        
        XCTAssertNoDiff(spy.values, [initial])
    }
    
    // MARK: - textField
    
    func test_shouldEmitDecimalValueOnTextFieldChange() {
        
        let initial = makeState(amount: 987)
        let (sut, textField, spy) = makeSUT(initialState: initial)
        
        textField.setText(to: nil)
        textField.setText(to: "abc")
        textField.setText(to: "abc123")
        textField.setText(to: "123")
        
        XCTAssertNoDiff(spy.values.map(\.amount), [987, 0, 123])
        XCTAssertNotNil(sut)
    }
    
    func test_textFieldShouldEmitFormatted() {
        
        let initial = makeState(amount: 987)
        let (sut, textField, _) = makeSUT(initialState: initial)
        let textFieldSpy = ValueSpy(textField.$state.map(\.text))
        
        textField.setText(to: nil)
        textField.setText(to: "abc")
        textField.setText(to: "abc123")
        textField.setText(to: "123")
        textField.setText(to: "12345")
        
        XCTAssertNoDiff(textFieldSpy.values, ["987 ₽", "", "0 ₽", "123 ₽", "12 345 ₽"])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - events
    
    func test_button_tap_shouldFinishEditing() {
        
        let initial = makeState(amount: 987)
        let (sut, textField, _) = makeSUT(initialState: initial)
        let textFieldSpy = ValueSpy(textField.$state)
        
        textField.startEditing()
        textField.setText(to: "123")
        sut.event(.button(.tap))
        
        XCTAssertNoDiff(textFieldSpy.values, [
            .noFocus("987 ₽"),
            .editing(.init("987 ₽", cursorAt: 5)),
            .editing(.init("123 ₽", cursorAt: 5)),
            .noFocus("123 ₽"),
        ])
    }
    
    func test_edit_shouldSetTextFieldValue() {
        
        let initial = makeState(amount: 987)
        let (sut, textField, _) = makeSUT(initialState: initial)
        let textFieldSpy = ValueSpy(textField.$state)
        
        textField.startEditing()
        textField.setText(to: "123")
        sut.event(.edit(567))
        
        XCTAssertNoDiff(textFieldSpy.values, [
            .noFocus("987 ₽"),
            .editing(.init("987 ₽", cursorAt: 5)),
            .editing(.init("123 ₽", cursorAt: 5)),
            .editing(.init("567 ₽", cursorAt: 5)),
        ])
    }
    
    func test_event_shouldCallReduceWithPayload() {
        
        var payload = [(SUT.State, SUT.Event)]()
        let initial = makeState(amount: 987)
        let (sut, _,_) = makeSUT(
            initialState: initial,
            reduce: {
                
                payload.append(($0, $1))
                return ($0, nil)
            }
        )
        
        sut.event(.button(.disable))
        
        XCTAssertNoDiff(payload.map(\.0), [initial])
        XCTAssertNoDiff(payload.map(\.1), [.button(.disable)])
    }
    
    func test_event_shouldChangeStateToReduced() {
        
        let initial = makeState(amount: 987)
        let newState = makeState(amount: 123)
        let (sut, _, spy) = makeSUT(
            initialState: initial,
            reduce: { _,_ in return (newState, nil) }
        )
        
        sut.event(.button(.disable))
        
        XCTAssertNoDiff(spy.values, [initial, newState])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FooterViewModel
    private typealias TextField = DecimalTextFieldViewModel
    private typealias Spy = ValueSpy<SUT.State>
    private typealias Reduce = (SUT.State, SUT.Event) -> (SUT.State, FooterEffect?)
    
    private func makeSUT(
        initialState: SUT.State? = nil,
        currencySymbol: String = "₽",
        locale: Locale = .init(identifier: "en_US"),
        reduce: @escaping Reduce = { state, _ in (state, nil) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        textField: TextField,
        spy: Spy
    ) {
        let formatter = DecimalFormatter(currencySymbol: currencySymbol)
        let textField = TextField.decimal(
            formatter: formatter,
            scheduler: .immediate
        )
        let sut = SUT(
            initialState: initialState ?? makeState(),
            reduce: reduce,
            format: formatter.format(_:),
            getDecimal: formatter.getDecimal(_:),
            textFieldModel: textField,
            scheduler: .immediate
        )
        
        let spy = Spy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(textField, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, textField, spy)
    }
    
    private func makeState(
        amount: Decimal = .init(Double.random(in: 1...1_000)),
        title: String = anyMessage(),
        buttonState: FooterState.FooterButton.ButtonState = .active,
        style: FooterState.Style = .amount
    ) -> SUT.State {
        
        return .init(
            amount: amount,
            button: .init(title: title, state: buttonState),
            style: style
        )
    }
}

private extension TextFieldState {
    
    var text: String {
        
        switch self {
        case let .placeholder(string):
            return string
            
        case let .noFocus(string):
            return string
            
        case let .editing(textState):
            return textState.text
        }
    }
}
