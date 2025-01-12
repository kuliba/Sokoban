//
//  MaskCleanTextTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 12.01.2025.
//

import XCTest

final class MaskCleanTextTests: XCTestCase {

    func test_shouldReturnEmpty_onEmptyWithEmptyPattern() {
        
        assert("", "", "")
    }
    
    func test_shouldReturnEmpty_onEmptyWithAnyPattern() {
        
        assert("", anyMessage(), "")
    }
    
    func test_shouldReturnSameString_onEmptyPattern() {
        
        let text = anyMessage()
        
        assert(text, "", text)
    }

    func test_shouldReturnSameString_onPatternWithAnySymbolPlaceholder() {
        
        let text = anyMessage()
        
        assert(text, "_", text)
        assert(text, "-_", text)
        assert(text, "-N_", text)
    }

    func test_shouldRemoveNonDigits_onDigitsOnlyPattern() {
        
        let text = "a3!"
        
        assert(text, "N", "3")
        assert(text, "+N", "3")
        assert(text, "-NNN", "3")
    }
    
    // MARK: - Helpers
    
    private func assert(
        _ text: String,
        _ pattern: String,
        _ expected: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let cleaned = Mask(pattern: pattern).clean(text)
        
        XCTAssertNoDiff(
            cleaned,
            expected,
            "Expected cleaned text to be \"\(expected)\" for pattern \"\(pattern)\", but got \"\(cleaned)\" instead.",
            file: file,
            line: line
        )
    }
}
