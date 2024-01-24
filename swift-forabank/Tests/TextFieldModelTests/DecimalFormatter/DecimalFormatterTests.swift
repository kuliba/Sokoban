//
//  DecimalFormatterTests.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import TextFieldModel
import XCTest

final class DecimalFormatterTests: XCTestCase {
    
    func test_number_shouldDeliverZeroFromNil() {
        
        let sut = makeSUT(currencySymbol: "RUB")

        let number = sut.number(from: nil)
        
        XCTAssertNoDiff(number, 0)
    }
    
    func test_number_shouldDeliverZeroFromNonNumber() {
        
        let nonNumber = " 123"
        let sut = makeSUT(currencySymbol: "RUB")

        let number = sut.number(from: nonNumber)
        
        XCTAssertNoDiff(number, 0)
    }
    
    func test_number_shouldDeliverZeroForNonFormatted() {
        
        let nonFormatted = "123"
        let sut = makeSUT(currencySymbol: "RUB")

        let number = sut.number(from: nonFormatted)
        
        XCTAssertNoDiff(number, 0)
    }
    
    func test_number_shouldDeliver___() {
        
        let nonFormatted = "123 RUB"
        let sut = makeSUT(currencySymbol: "RUB")

        let number = sut.number(from: nonFormatted)
        
        XCTAssertNoDiff(number, 123)
    }
    
    func test_rub() {
        
        assert(0, "0 RUB", for: "RUB")
        assert(123, "123 RUB", for: "RUB")
        assert(12.78, "12,78 RUB", for: "RUB")
        assert(123_456.78, "123 456,78 RUB", for: "RUB")
    }
    
    func test_rubSymbol() {
        
        assert(0, "0 ₽", for: "₽")
        assert(123, "123 ₽", for: "₽")
        assert(12.78, "12,78 ₽", for: "₽")
        assert(123_456.78, "123 456,78 ₽", for: "₽")
    }
    
    func test_emptyCurrency() {
        
        assert(0, "0 ", for: "")
        assert(123, "123 ", for: "")
        assert(12.78, "12,78 ", for: "")
        assert(123_456.78, "123 456,78 ", for: "")
    }
    
    func test_shouldReturnZeroFromUnformatted() {
        
        let string = "123"
        let sut = makeSUT(currencySymbol: "RUB")
        
        let reversed = sut.format(sut.number(from: string))
        
        XCTAssertNoDiff(reversed, "0 RUB")
    }
    
    func test_reverse() {
        
        let string = "123 RUB"
        let sut = makeSUT(currencySymbol: "RUB")
        
        let reversed = sut.format(sut.number(from: string))
        
        XCTAssertNoDiff(reversed, "123 RUB")
    }
    
    func test_number() {
        
        let formatted = "12 345 RUB"
        let sut = makeSUT(currencySymbol: "RUB")
        
        let number = sut.number(from: formatted)
        
        XCTAssertNoDiff(number, 12_345)
    }
    
    func test_filter_allowDecimalSeparator_true() throws {
        
        let decimal: Decimal = 12_345.67
        let sut = makeSUT(currencySymbol: "RUB")
        
        let clean = try sut.clean(
            text: XCTUnwrap(sut.format(decimal)),
            allowDecimalSeparator: true
        )
        
        XCTAssertNoDiff(clean, "12345,67")
    }
    
    func test_filter_allowDecimalSeparator_false() throws {
        
        let decimal: Decimal = 12_345.67
        let sut = makeSUT(currencySymbol: "RUB")
        
        let clean = try sut.clean(
            text: XCTUnwrap(sut.format(decimal)),
            allowDecimalSeparator: false
        )
        
        XCTAssertNoDiff(clean, "1234567")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DecimalFormatter
    
    private func makeSUT(
        currencySymbol: String = "₽",
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let locale = Locale(identifier: "ru_RU")
       
        return SUT(
            currencySymbol: currencySymbol,
            locale: locale
        )
    }
    
    private func assert(
        _ decimal: Decimal,
        _ expected: String,
        for currencySymbol: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT(currencySymbol: currencySymbol)
        
        let formatted = sut.format(decimal)
        let reversed = sut.number(from: formatted)
        
        XCTAssertNoDiff(formatted, expected, file: file, line: line)
        XCTAssertNoDiff(reversed, decimal, file: file, line: line)
    }
}
