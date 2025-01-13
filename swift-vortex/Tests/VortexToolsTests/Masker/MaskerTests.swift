//
//  MaskerTests.swift
//
//
//  Created by Igor Malyarov on 26.12.2024.
//

import VortexTools
import XCTest

final class MaskerTests: XCTestCase {
    
    // MARK: - No Mask
    
    func test_shouldDeliverUnmaskedInputOnNilMask() {
        
        let mask: String? = nil
        
        assert("abcdef", mask, "abcdef")
    }
    
    // MARK: - Empty Mask
    
    func test_shouldDeliverUnmaskedEmptyStringOnEmptyMask() {
        
        let mask = ""
        
        assert("", mask, "")
    }
    
    func test_shouldDeliverUnmaskedSingleDigitOnEmptyMask() {
        
        let mask = ""
        
        assert("5", mask, "5")
    }
    
    func test_shouldDeliverUnmaskedSingleLetterOnEmptyMask() {
        
        let mask = ""
        
        assert("a", mask, "a")
    }
    
    func test_shouldDeliverUnmaskedInputOnEmptyMask() {
        
        let mask = ""
        let input = anyMessage()
        
        assert(input, mask, input)
    }
    
    // MARK: - Single-Char Placeholders
    
    func test_shouldDeliverFirstDigitOnSingleNPlaceholder() {
        
        let mask = "N"
        
        assert("ab12c", mask, "1")
    }
    
    func test_shouldDeliverSingleCharOnSingleUnderscorePlaceholder() {
        
        let mask = "_"
        
        assert("abc", mask, "a")
    }
    
    // MARK: - Multi-Char Placeholders (with leading numbers)
    
    func test_shouldDeliverThreeDigitsOnDigitPlaceholderCount() {
        
        let mask = "3N"
        
        assert("a12b3c45", mask, "123")
    }
    
    func test_shouldDeliverFourCharsOnAnyPlaceholderCount() {
        
        let mask = "4_"
        
        assert("Hello", mask, "Hell")
    }
    
    func test_shouldDeliverConcatenatedLiteralAndDigitsOnLiteralBeforePlaceholder() {
        
        let mask = "Phone:2N"
        
        assert("abc123xxx", mask, "Phone:12")
    }
    
    // MARK: - Additional Masks
    
    func test_shouldDeliverPhoneNumberOnPlus7TripleCharDashTripleCharDashDoubleDashDouble() {
        
        let mask = "+7(___)-___-__-__"
        
        assert("9772697807", mask, "+7(977)-269-78-07")
    }
    
    func test_shouldDeliverSplitCharsOnUnderscoreDashUnderscore() {
        
        let mask = "____-____"
        
        assert("12345678", mask, "1234-5678")
    }
    
    func test_shouldDeliverShortDateOnDoubleUnderscoreDotDoubleUnderscore() {
        
        let mask = "__.__"
        
        assert("1124", mask, "11.24")
    }
    
    func test_shouldDeliverFullDateOnDoubleUnderscoreSlashQuadrupleUnderscore() {
        
        let mask = "__/____"
        
        assert("112024", mask, "11/2024")
    }
    
    // MARK: - Edge Cases
    
    func test_shouldDeliverPartialDigitsOnInsufficientInput() {
        
        let mask = "5N"
        
        assert("12", mask, "12")
    }
    
    func test_shouldIgnoreExtraInputOnSinglePlaceholder() {
        
        let mask = "N"
        
        assert("12345", mask, "1")
    }
    
    func test_shouldDeliverEmptyOnNoDigitsForDigitPlaceholder() {
        
        let mask = "3N"
        
        assert("abcdef", mask, "")
    }
    
    func test_shouldDeliverUnicodeCharsOnAnyPlaceholder() {
        
        let mask = "5_"
        
        assert("🥳✨Hello", mask, "🥳✨Hel")
    }
    
    func test_shouldDeliverAllDigitsOnArbitraryLargePlaceholder() {
        
        let mask = "9999N"
        let input = String(repeating: "1", count: 10_000)
        let expected = String(repeating: "1", count: 9_999)
        
        assert(input, mask, expected)
    }
    
    func test_shouldDeliverMultipleCharsOn10Underscores() {
        
        let mask = "10_"
        
        assert("ABCDEFGH123!", mask, "ABCDEFGH12",
               "Should take first 10 chars \"ABCDEFGH123!\" => \"ABCDEFGH12\"")
    }
    
    // MARK: - Helpers
    
    private func assert(
        _ input: String,
        _ mask: String?,
        _ expected: String,
        _ userMessage: String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let actual = Masker.mask(input, with: mask)
        let prefix = userMessage.map { "\($0): " } ?? ""
        
        XCTAssertNoDiff(
            actual,
            expected,
            "\(prefix)Expected \"\(expected)\" for mask \"\(String(describing: mask))\" of \"\(input)\", but got \"\(actual)\" instead.",
            file: file,
            line: line
        )
    }
}
