//
//  ChangingReducer_decimalWithMaxValueTests.swift
//
//
//  Created by Andryusina Nataly on 12.08.2024.
//

import TextFieldDomain
import TextFieldModel
import LandingUIComponent
import XCTest

final class ChangingReducer_decimalWithMaxValueTests: XCTestCase {
    
    func test_change_shouldNotChangeStateOnCursorAtEnd() throws {
        
        let newState = try change("0 ₽", with: "1", at: 3)
        
        assert(newState, hasText: "1 ₽", cursorAt: 1)
    }
    
    func test_change_shouldNotChangeStateOnCursorBeforeCurrencySymbol() throws {
        
        let newState = try change("0 ₽", with: "1", at: 2)
        
        assert(newState, hasText: "1 ₽", cursorAt: 1)
    }
    
    func test_change_shouldNotChangeStateOnCursorBeforeCurrencySymbol_RUB() throws {
        
        let newState = try change("0 RUB", with: "1", at: 2, currency: "RUB")
        
        assert(newState, hasText: "1 RUB", cursorAt: 1)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace() throws {
        
        let newState = try change("0 ₽", with: "1", at: 1)
        
        assert(newState, hasText: "1 ₽", cursorAt: 1)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace2() throws {
        
        let newState = try change("1 ₽", with: "2", at: 1)
        
        assert(newState, hasText: "12 ₽", cursorAt: 2)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace3() throws {
        
        let newState = try change("12 ₽", with: "3", at: 2)
        
        assert(newState, hasText: "123 ₽", cursorAt: 3)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace4() throws {
        
        let newState = try change("123 ₽", with: "4", at: 3)
        
        assert(newState, hasText: "1 234 ₽", cursorAt: 5)
    }
    
    func test_change_shouldNotChangeStateOnNonDigitInputWithCursorBeforeSpace4() throws {
        
        let newState = try change("123 ₽", with: "a", at: 3)
        
        assert(newState, hasText: "123 ₽", cursorAt: 3)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace5a() throws {
        
        let newState = try change("1234 ₽", with: "5", at: 4)
        
        assert(newState, hasText: "12 345 ₽", cursorAt: 6)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace5() throws {
        
        let newState = try change("1 234 ₽", with: "5", at: 5)
        
        assert(newState, hasText: "12 345 ₽", cursorAt: 6)
    }
    
    func test_change_shouldChangeStateOnCursorBeforeSpace6() throws {
        
        let newState = try change("12 345 ₽", with: "6", at: 6)
        
        assert(newState, hasText: "123 456 ₽", cursorAt: 7)
    }
    
    func test_change_shouldChangeStateOnCursorAt1() throws {
        
        let newState = try change("12 345 ₽", with: "6", at: 1)
        
        assert(newState, hasText: "162 345 ₽", cursorAt: 2)
    }
    
    func test_change_shouldChangeStateOnCursorAt2() throws {
        
        let newState = try change("12 345 ₽", with: "6", at: 2)
        
        assert(newState, hasText: "126 345 ₽", cursorAt: 3)
    }
    
    func test_change_shouldChangeStateOnCursorAt3() throws {
        
        let newState = try change("12 345 ₽", with: "6", at: 3)
        
        assert(newState, hasText: "126 345 ₽", cursorAt: 4)
    }
    
    func test_change_shouldChangeStateOnCursorAt4() throws {
        
        let newState = try change("12 345 ₽", with: "6", at: 4)
        
        assert(newState, hasText: "123 645 ₽", cursorAt: 5)
    }
    
    func test_change_shouldChangeStateOnCursorAt1_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 1)
        
        assert(newState, hasText: "182 345,67 ₽", cursorAt: 2)
    }
    
    func test_change_shouldChangeStateOnCursorAt2_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 2)
        
        assert(newState, hasText: "128 345,67 ₽", cursorAt: 3)
    }
    
    func test_change_shouldChangeStateOnCursorAt3_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 3)
        
        assert(newState, hasText: "128 345,67 ₽", cursorAt: 4)
    }
    
    func test_change_shouldChangeStateOnCursorAt4_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 4)
        
        assert(newState, hasText: "123 845,67 ₽", cursorAt: 5)
    }
    
    func test_change_shouldChangeStateOnCursorAt6_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 6)
        
        assert(newState, hasText: "123 458,67 ₽", cursorAt: 7)
    }
    
    func test_change_shouldChangeStateOnCursorAt7_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 7)
        
        assert(newState, hasText: "12 345,87 ₽", cursorAt: 7)
    }
    
    func test_change_shouldChangeStateOnCursorAt8_decimals() throws {
        
        let newState = try change("12 345,67 ₽", with: "8", at: 8)
        
        assert(newState, hasText: "12 345,69 ₽", cursorAt: 8)
    }
    
    func test_change_shouldChangeStateOnCursorAt1_RUB() throws {
        
        let newState = try change("12 345 RUB", with: "6", at: 1, currency: "RUB")
        
        assert(newState, hasText: "162 345 RUB", cursorAt: 2)
    }
    
    func test_change_shouldChangeStateOnCursorAt2_RUB() throws {
        
        let newState = try change("12 345 RUB", with: "6", at: 2, currency: "RUB")
        
        assert(newState, hasText: "126 345 RUB", cursorAt: 3)
    }
    
    func test_change_shouldChangeStateOnCursorAt3_RUB() throws {
        
        let newState = try change("12 345 RUB", with: "6", at: 3, currency: "RUB")
        
        assert(newState, hasText: "126 345 RUB", cursorAt: 4)
    }
    
    func test_change_shouldChangeStateOnCursorAt4_RUB() throws {
        
        let newState = try change("12 345 RUB", with: "6", at: 4, currency: "RUB")
        
        assert(newState, hasText: "123 645 RUB", cursorAt: 5)
    }
    
    func test_change_shouldIgnoreSecondDecimalSeparatorAt3() throws {
        
        let newState = try change("12 345,67 ₽", with: ",.", at: 3)

        assert(newState, hasText: "12 345,67 ₽", cursorAt: 3)
    }
    
    func test_change_shouldIgnoreSecondDecimalSeparator() throws {
        
        let newState = try change("12 345,67 ₽", with: ",.", at: 8)

        assert(newState, hasText: "12 345,67 ₽", cursorAt: 8)
    }
    
    func test_change_shouldAddTrailingZero() throws {
        
        let newState = try change("12, ₽", with: "0", at: 3)

        assert(newState, hasText: "12,0 ₽", cursorAt: 4)
    }
    
    func test_change_shouldRemoveDecimalSeparatorOnSecondDecimalZero() throws {
        
        let newState = try change("12,0 ₽", with: "0", at: 4)

        assert(newState, hasText: "12 ₽", cursorAt: 2)
    }
    
    func test_change_shouldNotChangedIfNewValueMoreThenMaxValue() throws {
        
        let newState = try change("10 ₽", with: "11", at: 3, maxValue: 10)

        assert(newState, hasText: "10 ₽", cursorAt: 2)
    }

    // MARK: - Helpers
    
    private typealias SUT = ChangingReducer
    
    private func makeSUT(
        currencySymbol: String = "₽",
        locale: Locale = .init(identifier: "ru_RU"),
        maxValue: Decimal
    ) -> SUT {

        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol,
            locale: locale
        )
        
        return ChangingReducer.decimal(formatter: formatter, maxValue: maxValue)
    }
    
    private func change(
        _ text: String,
        with replacementText: String,
        at cursorPosition: Int,
        selected rangeLength: Int = 0,
        currency currencySymbol: String = "₽",
        locale: Locale = .init(identifier: "ru_RU"),
        maxValue: Decimal = 999999
    ) throws -> TextFieldState {
        
        let state: TextFieldState = .editing(.init(
            text,
            cursorPosition: cursorPosition
        ))
        let action: TextFieldAction = .changeText(
            replacementText,
            in: .init(location: cursorPosition, length: rangeLength)
        )
        
        let sut = makeSUT(
            currencySymbol: currencySymbol,
            locale: locale,
            maxValue: maxValue
        )
        
        return try sut.reduce(state, with: action)
    }
    
    private func assert(
        _ state: TextFieldState,
        hasText text: String,
        cursorAt cursorPosition: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch state {
        case .placeholder, .noFocus:
            XCTFail("Expected editing state, got \(state) instead.", file: file, line: line)
            
        case let .editing(textState):
            XCTAssertNoDiff(textState.text, text, "Expected text \"\(text)\" but got \"\(textState.text)\" instead.", file: file, line: line)
            XCTAssertNoDiff(textState.cursorPosition, cursorPosition, "Expected cursor at \(cursorPosition) but got at \(textState.cursorPosition) instead.", file: file, line: line)
        }
    }
}
