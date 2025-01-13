//
//  FooterViewModelConvenienceTests.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import AmountComponent
import TextFieldDomain
import TextFieldComponent
import XCTest

final class FooterViewModelConvenienceTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetInitialValue() {
        
        let initial = makeState(amount: 987)
        let (_, spy) = makeSUT(initialState: initial)
        
        XCTAssertNoDiff(spy.values, [initial])
    }
    
    // MARK: - events
    
    func test_disableButton_shouldChangeButtonStateToInactive() {
        
        let initial = makeState(amount: 987)
        let (sut, spy) = makeSUT(initialState: initial)
        
        sut.event(.button(.disable))
        
        XCTAssertEqual(spy.values.count, 2)
        XCTAssertNoDiff(spy.values.last?.button.state, .inactive)
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
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let sut = SUT(
            initialState: initialState ?? makeState(),
            currencySymbol: currencySymbol,
            locale: locale,
            scheduler: .immediate
        )
        
        let spy = Spy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
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
