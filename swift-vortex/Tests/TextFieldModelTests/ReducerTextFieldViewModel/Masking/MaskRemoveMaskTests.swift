//
//  MaskRemoveMaskTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 11.01.2025.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class MaskRemoveMaskTests: MaskTests {
    
    func test_unmask_empty_shouldDeliverEmpty_onEmptyState() {
        
        assertUnmask("", with: "", is: .empty)
    }
    
    func test_unmask_empty_shouldDeliverSame() {
        
        let state = makeState(anyMessage())
        
        assertUnmask(state, with: "", is: state)
    }
    
    func test_unmask_mixedPlaceholders_shouldHandleDigitsAndLetters() {
        
        assertUnmask("123-AB4", with: "NNN-__N", before: "123AB4", after: "")
    }
    
    func test_unmask_shouldIgnoreStaticCharactersWithinInput() {
        
        assertUnmask("123-456", with: "NNN-NNN", before: "123456", after: "")
    }
    
    func test_unmask_overfilledInput_shouldIgnoreExtraCharacters() {
        
        assertUnmask("123-45-6789", with: "NNN-NN", before: "12345", after: "")
    }
    
    func test_unmask_onlyPlaceholders_shouldLimitLength() {
        
        assertUnmask("ABCDEF", with: "_____", before: "ABCDE", after: "")
    }
    
    func test_unmask_onlyPlaceholders_shouldPassThrough() {
        
        assertUnmask("ABCDEF", with: "______", before: "ABCDEF", after: "")
    }
    
    func test_unmask_phone_shouldDeliverEmpty_onEmptyState() {
        
        let state = makeState("")
        let pattern = "+7(___)-___-__-__"
        
        assertUnmask(state, with: pattern, is: .empty)
    }
    
    func test_unmask_phone() {
        
        let pattern = "+7(___)-___-__-__"
        
        assertUnmask("+7(", with: pattern, before: "", after: "")
        
        assertUnmask("+7(9", cursorAt: 0, with: pattern, before: "", after: "9")
        assertUnmask("+7(9", cursorAt: 1, with: pattern, before: "", after: "9")
        assertUnmask("+7(9", cursorAt: 2, with: pattern, before: "", after: "9")
        assertUnmask("+7(9", cursorAt: 3, with: pattern, before: "", after: "9")
        assertUnmask("+7(9", cursorAt: 4, with: pattern, before: "9", after: "")
        
        assertUnmask("+7(99", cursorAt: 0, with: pattern, before: "", after: "99")
        assertUnmask("+7(99", cursorAt: 1, with: pattern, before: "", after: "99")
        assertUnmask("+7(99", cursorAt: 2, with: pattern, before: "", after: "99")
        assertUnmask("+7(99", cursorAt: 3, with: pattern, before: "", after: "99")
        assertUnmask("+7(99", cursorAt: 4, with: pattern, before: "9", after: "9")
        assertUnmask("+7(99", cursorAt: 5, with: pattern, before: "99", after: "")
        
        assertUnmask("+7(999", cursorAt: 0, with: pattern, before: "", after: "999")
        assertUnmask("+7(999", cursorAt: 1, with: pattern, before: "", after: "999")
        assertUnmask("+7(999", cursorAt: 2, with: pattern, before: "", after: "999")
        assertUnmask("+7(999", cursorAt: 3, with: pattern, before: "", after: "999")
        assertUnmask("+7(999", cursorAt: 4, with: pattern, before: "9", after: "99")
        assertUnmask("+7(999", cursorAt: 5, with: pattern, before: "99", after: "9")
        assertUnmask("+7(999", cursorAt: 6, with: pattern, before: "999", after: "")
        
        assertUnmask("+7(999)", cursorAt: 0, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)", cursorAt: 1, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)", cursorAt: 2, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)", cursorAt: 3, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)", cursorAt: 4, with: pattern, before: "9", after: "99")
        assertUnmask("+7(999)", cursorAt: 5, with: pattern, before: "99", after: "9")
        assertUnmask("+7(999)", cursorAt: 6, with: pattern, before: "999", after: "")
        assertUnmask("+7(999)", cursorAt: 7, with: pattern, before: "999", after: "")
        
        assertUnmask("+7(999)-", cursorAt: 0, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)-", cursorAt: 1, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)-", cursorAt: 2, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)-", cursorAt: 3, with: pattern, before: "", after: "999")
        assertUnmask("+7(999)-", cursorAt: 4, with: pattern, before: "9", after: "99")
        assertUnmask("+7(999)-", cursorAt: 5, with: pattern, before: "99", after: "9")
        assertUnmask("+7(999)-", cursorAt: 6, with: pattern, before: "999", after: "")
        assertUnmask("+7(999)-", cursorAt: 7, with: pattern, before: "999", after: "")
        assertUnmask("+7(999)-", cursorAt: 8, with: pattern, before: "999", after: "")
        
        assertUnmask("+7(123)-456-78-912", with: pattern, before: "1234567891", after: "")
    }
    
    // MARK: - Helpers
    
    private func unmask(
        _ state: TextState,
        with pattern: String
    ) -> TextState {
        
        let mask = Mask(pattern: pattern)
        
        return mask.removeMask(from: state)
    }
    
    private func assertUnmask(
        _ text: String,
        cursorAt cursorPosition: Int? = nil,
        with pattern: String,
        is expectedState: TextState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let state = makeState(text, cursorAt: cursorPosition)
        assertUnmask(state, with: pattern, is: expectedState, file: file, line: line)
    }
    
    private func assertUnmask(
        _ state: TextState,
        with pattern: String,
        is expectedState: TextState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let unmasked = unmask(state, with: pattern)
        
        XCTAssertNoDiff(unmasked, expectedState, "Expected \(expectedState), but got \(unmasked) instead.", file: file, line: line)
    }
    
    private func assertUnmask(
        _ text: String,
        cursorAt cursorPosition: Int? = nil,
        with pattern: String,
        before beforeCursor: String = "",
        after afterCursor: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let state = makeState(text, cursorAt: cursorPosition)
        let unmasked = unmask(state, with: pattern)
        let parts = unmasked.parts
        
        XCTAssertNoDiff(parts.beforeCursor, beforeCursor, "Expected \"\(beforeCursor)\" before cursor, but got \"\(parts.beforeCursor)\" instead.", file: file, line: line)
        XCTAssertNoDiff(parts.afterCursor, afterCursor, "Expected \"\(afterCursor)\" after cursor, but got \"\(parts.afterCursor)\" instead.", file: file, line: line)
    }
}
