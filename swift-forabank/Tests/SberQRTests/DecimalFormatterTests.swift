//
//  DecimalFormatterTests.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

@testable import SberQR
import XCTest

final class DecimalFormatterTests: XCTestCase {
    
    func test_number_shouldDeliverZeroFromNil() {
        
        let sut = SUT(currencySymbol: "RUB")

        let number = sut.number(nil)
        
        XCTAssertNoDiff(number, 0)
    }
    
    func test_number_shouldDeliverZeroFromNonNumber() {
        
        let nonNumber = " 123"
        let sut = SUT(currencySymbol: "RUB")

        let number = sut.number(nonNumber)
        
        XCTAssertNoDiff(number, 0)
    }
    
    func test_rub() {
        
        assert(123, "123 RUB", for: "RUB")
        assert(12.78, "12,78 RUB", for: "RUB")
        assert(123_456.78, "123 456,78 RUB", for: "RUB")
    }
    
    func test_rubSymbol() {
        
        assert(123, "123 ₽", for: "₽")
        assert(12.78, "12,78 ₽", for: "₽")
        assert(123_456.78, "123 456,78 ₽", for: "₽")
    }
    
    func test_emptyCurrency() {
        
        assert(123, "123 ", for: "")
        assert(12.78, "12,78 ", for: "")
        assert(123_456.78, "123 456,78 ", for: "")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DecimalFormatter
    
    private func assert(
        _ decimal: Decimal,
        _ expected: String,
        for currencySymbol: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = SUT(currencySymbol: currencySymbol)
        
        let formatted = sut.format(decimal)
        let reversed = sut.number(formatted)
        
        XCTAssertNoDiff(formatted, expected, file: file, line: line)
        XCTAssertNoDiff(reversed, decimal, file: file, line: line)
    }
}
