//
//  MaskTests.swift
//
//
//  Created by Igor Malyarov on 10.01.2025.
//

import TextFieldDomain

struct Mask {
    
    private let pattern: String
    
    @inlinable
    init(pattern: String) {
        
        self.pattern = pattern
    }
}

extension Character {
    
    @usableFromInline
    var isPlaceholder: Bool { self == "N" || self == "_" }
}

extension Mask {
    
    /// Removes static characters from masked input and adjusts the cursor accordingly.
    @inlinable
    func unmask(
        _ state: TextState
    ) -> TextState {
        
        guard !pattern.isEmpty else { return state }
        
        let maskedText = state.text
        let cursorPosition = state.cursorPosition
        
        var rawText = ""
        var rawCursorPosition = 0
        
        let maskedChars = Array(maskedText)
        let patternChars = Array(pattern)
        
        var rawIndex = 0
        
        for (index, char) in maskedChars.enumerated() {
            
            if index >= patternChars.count {
                // Ignore any extra characters beyond the mask
                break
            }
            
            let patternChar = patternChars[index]
            
            if patternChar.isPlaceholder {
                
                rawText.append(char)
                
                if index < cursorPosition {
                    rawCursorPosition += 1
                }
                
                rawIndex += 1
            } else {
                
                // Skip non-placeholder
                if index < cursorPosition {
                    // If cursor was after this static character, shift left
                    rawCursorPosition = rawIndex
                }
            }
        }
        
        return .init(rawText, cursorPosition: rawCursorPosition)
    }
}

@testable import TextFieldDomain
import XCTest

final class MaskTests: XCTestCase {
    
    // MARK: - unmask
    
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
    
    private func makeState(
        _ text: String,
        cursorAt cursorPosition: Int? = nil
    ) -> TextState {
        
        return .init(text, cursorPosition: cursorPosition ?? text.utf16.count)
    }
    
    private func unmask(
        _ state: TextState,
        with pattern: String
    ) -> TextState {
        
        let mask = Mask(pattern: pattern)
        
        return mask.unmask(state)
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

#warning("edge case: deleting before first character in unmasked text should have no effect if unmasked text is not empty and set to empty masked text if unmasked text is empty -??")

extension Mask {
    
    /// Maps a range in the masked text to the corresponding range in the unmasked text.
    @inlinable
    func unmask(_ range: Range<Int>) -> Range<Int> {
        
        guard !pattern.isEmpty else { return range }
        
        let patternChars = Array(pattern)
        
        var maskedToUnmasked: [Int] = []
        var unmaskedIndex = 0
        
        // Step 1: Build a mapping from masked indices to unmasked indices
        for patternChar in patternChars {
            
            if patternChar.isPlaceholder {
                // Placeholder character contributes to the unmasked text
                maskedToUnmasked.append(unmaskedIndex)
                unmaskedIndex += 1
            } else {
                // Static character does not contribute
                maskedToUnmasked.append(unmaskedIndex)
            }
        }
        
        // Step 2: Clamp the input range to the bounds of the mapping
        let clampedLowerBound = max(0, min(range.lowerBound, maskedToUnmasked.count - 1))
        let clampedUpperBound = max(0, min(range.upperBound, maskedToUnmasked.count))
        
        // Step 3: Map the clamped range to the unmasked range
        let startUnmaskedIndex = maskedToUnmasked[clampedLowerBound]
        let endUnmaskedIndex = clampedUpperBound > 0
        ? maskedToUnmasked[clampedUpperBound - 1] + (patternChars[clampedUpperBound - 1].isPlaceholder ? 1 : 0)
        : startUnmaskedIndex
        
        return startUnmaskedIndex..<endUnmaskedIndex
    }
}

extension MaskTests {
    
    // MARK: - unmask(range:)
    
    func test_unmaskRange_negativeOutOfBounds() {
        
        assertUnmasked(-10..<(-1), with: "+7(___)-___-__-__", is: 0..<0)
    }
    
    func test_unmaskRange_emptyMask() {
        
        assertUnmasked(0..<5,  with: "", is: 0..<5)
        assertUnmasked(0..<0,  with: "", is: 0..<0)
        assertUnmasked(5..<10, with: "", is: 5..<10)
    }
    
    func test_unmaskRange_phone() {
        
        //     0..<18 "12345678901234567
        //     0..<18 "+7(123)-456-78-90", is: 0..<10
        let pattern = "+7(___)-___-__-__"
        
        assertUnmasked(0..<0,   with: pattern, is: 0..<0)
        assertUnmasked(0..<2,   with: pattern, is: 0..<0)
        assertUnmasked(0..<3,   with: pattern, is: 0..<0)
        assertUnmasked(0..<5,   with: pattern, is: 0..<2)
        assertUnmasked(0..<18,  with: pattern, is: 0..<10)
        assertUnmasked(0..<50,  with: pattern, is: 0..<10)
        assertUnmasked(0..<100, with: pattern, is: 0..<10)
        assertUnmasked(2..<5,   with: pattern, is: 0..<2)
        assertUnmasked(2..<8,   with: pattern, is: 0..<3)
        assertUnmasked(3..<4,   with: pattern, is: 0..<1)
        assertUnmasked(3..<5,   with: pattern, is: 0..<2)
        assertUnmasked(4..<7,   with: pattern, is: 1..<3)
        assertUnmasked(4..<8,   with: pattern, is: 1..<3)
        assertUnmasked(5..<10,  with: pattern, is: 2..<5)
        assertUnmasked(5..<50,  with: pattern, is: 2..<10)
        assertUnmasked(6..<9,   with: pattern, is: 3..<4)
        assertUnmasked(7..<8,   with: pattern, is: 3..<3)
        assertUnmasked(8..<15,  with: pattern, is: 3..<8)
        assertUnmasked(9..<13,  with: pattern, is: 4..<7)
        assertUnmasked(12..<13, with: pattern, is: 6..<7)
        assertUnmasked(15..<17, with: pattern, is: 8..<10)
        assertUnmasked(16..<18, with: pattern, is: 9..<10)
    }
    
    func test_unmaskRange_placeholderOnly() {
        
        // "NNNNN" → max unmasked length = 5
        assertUnmasked(0..<5, with:  "NNNNN", is: 0..<5)
        assertUnmasked(2..<4, with:  "NNNNN", is: 2..<4)
        assertUnmasked(0..<0, with:  "NNNNN", is: 0..<0)
        assertUnmasked(4..<10, with: "NNNNN", is: 4..<5)
    }
    
    func test_unmaskRange_staticOnly() {
        
        // "+7 ( ) -" → no placeholders
        assertUnmasked(0..<8, with: "+7 ( ) -", is: 0..<0)
        assertUnmasked(2..<4, with: "+7 ( ) -", is: 0..<0)
        assertUnmasked(0..<0, with: "+7 ( ) -", is: 0..<0)
    }
    
    func test_unmaskRange_staticAndPlaceholderMix() {
        
        //             0..<6         "123456" is:
        //             0..<6         "AB123C" is:
        //             0..<6         "AB_N_C" is:
        assertUnmasked(0..<6, with: "AB_N_C", is: 0..<3)
        assertUnmasked(3..<4, with: "AB_N_C", is: 1..<2)
        assertUnmasked(1..<5, with: "AB_N_C", is: 0..<3)
    }
    
    func test_unmaskRange_edgeCases() {
        
        //             0..<8          "1234567"
        //             0..<8          "(12)-34"
        //             0..<8          "(__)-__"
        assertUnmasked(-5..<2,  with: "(__)-__", is: 0..<1)
        assertUnmasked(0..<2,   with: "(__)-__", is: 0..<1)
        assertUnmasked(0..<8,   with: "(__)-__", is: 0..<4)
        assertUnmasked(1..<4,   with: "(__)-__", is: 0..<2)
        assertUnmasked(3..<100, with: "(__)-__", is: 2..<4)
        assertUnmasked(5..<5,   with: "(__)-__", is: 2..<2)
        assertUnmasked(6..<6,   with: "(__)-__", is: 3..<3)
    }
    
    func test_unmaskRange_staticEdges() {
        
        //                          "+N-N+"
        assertUnmasked(0..<1, with: "+N-N+", is: 0..<0)
        assertUnmasked(1..<2, with: "+N-N+", is: 0..<1)
        assertUnmasked(4..<5, with: "+N-N+", is: 2..<2)
        assertUnmasked(0..<5, with: "+N-N+", is: 0..<2)
    }
    
    func test_unmaskRange_overlappingStaticAndPlaceholder() {
        
        //                          "+7(__)-__"
        assertUnmasked(2..<6, with: "+7(__)-__", is: 0..<2)
        assertUnmasked(5..<9, with: "+7(__)-__", is: 2..<4)
    }
    
    func test_unmaskRange_singlePlaceholder() {
        
        assertUnmasked(0..<1, with: "N", is: 0..<1)
        assertUnmasked(0..<0, with: "N", is: 0..<0)
        assertUnmasked(-5..<2, with: "N", is: 0..<1)
    }
    
    func test_unmaskRange_alternatingStaticAndPlaceholder() {
        
        //                           "12345678901"
        //                           "A123B456C78"
        assertUnmasked(0..<11, with: "A_N_B_N_C_N", is: 0..<8)
        assertUnmasked(1..<5,  with: "A_N_B_N_C_N", is: 0..<3)
        assertUnmasked(2..<3,  with: "A_N_B_N_C_N", is: 1..<2)
    }
    
    func test_unmaskRange_noPlaceholders() {
        
        assertUnmasked(0..<7,   with: "ABC-DEF", is: 0..<0)
        assertUnmasked(0..<100, with: "ABC-DEF", is: 0..<0)
        assertUnmasked(3..<5,   with: "ABC-DEF", is: 0..<0)
    }
    
    func test_unmaskRange_consecutivePlaceholders() {
        
        //                          "NNN-___-NN"
        assertUnmasked(0..<3, with: "NNN-___-NN", is: 0..<3)
        assertUnmasked(4..<7, with: "NNN-___-NN", is: 3..<6)
        assertUnmasked(7..<9, with: "NNN-___-NN", is: 6..<7)
    }
    // MARK: - Helpers
    
    private func assertUnmasked(
        _ range: Range<Int>,
        with pattern: String,
        is expected: Range<Int>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let mask = Mask(pattern: pattern)
        let unmasked = mask.unmask(range)
        
        XCTAssertNoDiff(unmasked, expected, "Expected \(expected) range, but got \(unmasked) instead.", file: file, line: line)
    }
}

extension Mask {
    
    /// Applies the mask pattern to the provided unmasked `TextState`.
    @inlinable
    func mask(
        _ state: TextState
    ) -> TextState {
        
        guard !pattern.isEmpty else { return state }
        guard !state.text.isEmpty else { return .empty }
        
        let patternChars = Array(pattern)
        let rawChars = Array(state.text)
        
        var rawIndex = 0
        var maskedText = ""
        
        for patternChar in patternChars {
            
            if patternChar.isPlaceholder {
                
                if rawIndex < rawChars.count {
                    
                    maskedText.append(rawChars[rawIndex])
                    rawIndex += 1
                    
                } else {
                    break
                }
                
            } else {
                
                // Reveal static characters only when there's preceding input
                maskedText.append(patternChar)
            }
        }
        
        let maskedCursorPosition = pattern.maskedIndex(
            for: state.cursorPosition
        )
        
        return .init(maskedText, cursorPosition: maskedCursorPosition)
    }
}

extension MaskTests {
    
    // MARK: - mask(_: TextState)
    
    func test_mask_emptyMask_shouldReturnSameState() {
        
        let state = makeState("12345", cursorAt: 3)
        
        assertMasked(state, with: "", is: state)
    }
    
    func test_mask_phoneNumber() {
        
        let pattern = "+7(___)-___-__-__"
        
        assertMasked("",            with: pattern, is: "")
        assertMasked("1",           with: pattern, is: "+7(1")
        assertMasked("12",          with: pattern, is: "+7(12")
        assertMasked("123",         with: pattern, is: "+7(123)-")
        assertMasked("1234",        with: pattern, is: "+7(123)-4")
        assertMasked("12345",       with: pattern, is: "+7(123)-45")
        assertMasked("123456",      with: pattern, is: "+7(123)-456-")
        assertMasked("1234567",     with: pattern, is: "+7(123)-456-7")
        assertMasked("12345678",    with: pattern, is: "+7(123)-456-78-")
        assertMasked("123456789",   with: pattern, is: "+7(123)-456-78-9")
        assertMasked("1234567890",  with: pattern, is: "+7(123)-456-78-90")
        assertMasked("12345678901", with: pattern, is: "+7(123)-456-78-90")
    }
    
    func test_mask_phoneNumber_withCursorPositions() {
        
        let pattern = "+7(___)-___-__-__"
        
        assertMasked("",            cursorAt: 0, with: pattern, is: "",                  cursorAt: 0)
        assertMasked("1",           cursorAt: 0, with: pattern, is: "+7(1",              cursorAt: 3)
        assertMasked("12",          cursorAt: 1, with: pattern, is: "+7(12",             cursorAt: 4)
        assertMasked("123",         cursorAt: 2, with: pattern, is: "+7(123)-",          cursorAt: 7)
        assertMasked("1234",        cursorAt: 3, with: pattern, is: "+7(123)-4",         cursorAt: 8)
        assertMasked("12345",       cursorAt: 4, with: pattern, is: "+7(123)-45",        cursorAt: 9)
        assertMasked("123456",      cursorAt: 5, with: pattern, is: "+7(123)-456-",      cursorAt: 11)
        assertMasked("1234567",     cursorAt: 6, with: pattern, is: "+7(123)-456-7",     cursorAt: 12)
        assertMasked("12345678",    cursorAt: 7, with: pattern, is: "+7(123)-456-78-",   cursorAt: 14)
        assertMasked("123456789",   cursorAt: 8, with: pattern, is: "+7(123)-456-78-9",  cursorAt: 15)
        assertMasked("1234567890",  cursorAt: 9, with: pattern, is: "+7(123)-456-78-90", cursorAt: 16)
    }
    
    func test_mask_dateShort() {
        
        let pattern = "__.__"
        
        assertMasked("1",     with: pattern, is: "1")
        assertMasked("12",    with: pattern, is: "12.")
        assertMasked("123",   with: pattern, is: "12.3")
        assertMasked("1234",  with: pattern, is: "12.34")
        assertMasked("12345", with: pattern, is: "12.34")
    }
    
    func test_mask_dateShort_withCursorPositions() {
        
        let pattern = "__.__"
        
        assertMasked("1",    cursorAt: 0, with: pattern, is: "1",     cursorAt: 0)
        assertMasked("12",   cursorAt: 1, with: pattern, is: "12.",   cursorAt: 2)
        assertMasked("123",  cursorAt: 2, with: pattern, is: "12.3",  cursorAt: 3)
        assertMasked("1234", cursorAt: 3, with: pattern, is: "12.34", cursorAt: 4)
    }
    
    func test_mask_dateLong() {
        
        let pattern = "__.____"
        
        assertMasked("1",       with: pattern, is: "1")
        assertMasked("12",      with: pattern, is: "12.")
        assertMasked("123",     with: pattern, is: "12.3")
        assertMasked("1234",    with: pattern, is: "12.34")
        assertMasked("12345",   with: pattern, is: "12.345")
        assertMasked("123456",  with: pattern, is: "12.3456")
        assertMasked("1234567", with: pattern, is: "12.3456")
    }
    
    func test_mask_dateLong_withCursorPositions() {
        
        let pattern = "__.____"
        
        assertMasked("1",      cursorAt: 0, with: pattern, is: "1",       cursorAt: 0)
        assertMasked("12",     cursorAt: 1, with: pattern, is: "12.",     cursorAt: 2)
        assertMasked("123",    cursorAt: 2, with: pattern, is: "12.3",    cursorAt: 3)
        assertMasked("1234",   cursorAt: 3, with: pattern, is: "12.34",   cursorAt: 4)
        assertMasked("12345",  cursorAt: 4, with: pattern, is: "12.345",  cursorAt: 5)
        assertMasked("123456", cursorAt: 5, with: pattern, is: "12.3456", cursorAt: 6)
    }
    
    func test_mask_placeholderOnly() {
        
        let pattern = "NNN_NNN"
        
        assertMasked("123",      with: pattern, is: "123")
        assertMasked("123456",   with: pattern, is: "123456")
        assertMasked("1234567",  with: pattern, is: "1234567")
        assertMasked("12345678", with: pattern, is: "1234567")
    }
    
    func test_mask_placeholderOnly_withCursorPositions() {
        
        let pattern = "NNN_NNN"
        
        assertMasked("123",    cursorAt: 0, with: pattern, is: "123",    cursorAt: 0)
        assertMasked("123456", cursorAt: 3, with: pattern, is: "123456", cursorAt: 3)
    }
    
    func test_mask_staticOnly_shouldIncludeAllStaticChars() {
        
        let pattern = "+7 ( ) -"
        
        assertMasked("",    with: pattern, is: "")
        assertMasked("123", with: pattern, is: "+7 ( ) -")
    }
    
    func test_mask_staticAndPlaceholderMix() {
        
        let pattern = "AB_N_C"
        
        assertMasked("1",    with: pattern, is: "AB1")
        assertMasked("12",   with: pattern, is: "AB12")
        assertMasked("123",  with: pattern, is: "AB123C")
        assertMasked("1234", with: pattern, is: "AB123C")
    }
    
    func test_mask_staticAndPlaceholderMix_withCursorPositions() {
        
        let pattern = "AB_N_C"
        
        assertMasked("1",   cursorAt: 0, with: pattern, is: "AB1",    cursorAt: 2)
        assertMasked("12",  cursorAt: 1, with: pattern, is: "AB12",   cursorAt: 3)
        assertMasked("123", cursorAt: 2, with: pattern, is: "AB123C", cursorAt: 5)
    }
    func test_mask_edgeCases() {
        
        let pattern = "(__)-__"
        
        assertMasked("",      with: pattern, is: "")
        assertMasked("1",     with: pattern, is: "(1")
        assertMasked("12",    with: pattern, is: "(12)-")
        assertMasked("123",   with: pattern, is: "(12)-3")
        assertMasked("1234",  with: pattern, is: "(12)-34")
        assertMasked("12345", with: pattern, is: "(12)-34")
    }
    
    func test_mask_staticOnly_withCursorPositions() {
        
        let pattern = "+7 ( ) -"
        
        assertMasked("",   cursorAt: 0, with: pattern, is: "",         cursorAt: 0)
        assertMasked("1",  cursorAt: 0, with: pattern, is: "+7 ( ) -", cursorAt: 8)
        assertMasked("12", cursorAt: 1, with: pattern, is: "+7 ( ) -", cursorAt: 8)
    }
    
    func test_mask_edgeCases_withCursorPositions() {
        
        let pattern = "(__)-__"
        
        assertMasked("1",   cursorAt: 0, with: pattern, is: "(1",     cursorAt: 1)
        assertMasked("12",  cursorAt: 1, with: pattern, is: "(12)-",  cursorAt: 4)
        assertMasked("123", cursorAt: 2, with: pattern, is: "(12)-3", cursorAt: 5)
    }
    
    func test_mask_alternatingStaticAndPlaceholder() {
        
        let pattern = "A_N_B_N_C_N"
        
        assertMasked("1",    with: pattern, is: "A1")
        assertMasked("12",   with: pattern, is: "A12")
        assertMasked("123",  with: pattern, is: "A123B")
        assertMasked("1234", with: pattern, is: "A123B4")
    }
    
    // MARK: - Helpers
    
    private func mask(
        _ state: TextState,
        with pattern: String
    ) -> TextState {
        
        let mask = Mask(pattern: pattern)
        return mask.mask(state)
    }
    
    private func assertMasked(
        _ text: String,
        cursorAt cursorPosition: Int? = nil,
        with pattern: String,
        is expectedText: String,
        cursorAt expectedCursor: Int? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let state = makeState(text, cursorAt: cursorPosition)
        let expectedState = makeState(expectedText, cursorAt: expectedCursor)
        let masked = mask(state, with: pattern)
        
        XCTAssertNoDiff(masked, expectedState, "Expected \(expectedState), but got \(masked) instead.", file: file, line: line)
    }
    
    private func assertMasked(
        _ state: TextState,
        with pattern: String,
        is expectedState: TextState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let masked = mask(state, with: pattern)
        
        XCTAssertNoDiff(masked, expectedState, "Expected \(expectedState), but got \(masked) instead.", file: file, line: line)
    }
}
