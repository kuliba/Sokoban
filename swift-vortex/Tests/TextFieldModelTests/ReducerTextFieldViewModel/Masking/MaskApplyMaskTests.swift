//
//  MaskApplyMaskTests.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

@testable import TextFieldDomain
import XCTest

final class MaskApplyMaskTests: MaskTests {
    
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
        
        assertMasked("",           at: 0, with: pattern, is: "",                  at: 0)
        assertMasked("1",          at: 0, with: pattern, is: "+7(1",              at: 3)
        assertMasked("12",         at: 1, with: pattern, is: "+7(12",             at: 4)
        assertMasked("123",        at: 2, with: pattern, is: "+7(123)-",          at: 7)
        assertMasked("1234",       at: 3, with: pattern, is: "+7(123)-4",         at: 8)
        assertMasked("12345",      at: 4, with: pattern, is: "+7(123)-45",        at: 9)
        assertMasked("123456",     at: 5, with: pattern, is: "+7(123)-456-",      at: 11)
        assertMasked("1234567",    at: 6, with: pattern, is: "+7(123)-456-7",     at: 12)
        assertMasked("12345678",   at: 7, with: pattern, is: "+7(123)-456-78-",   at: 14)
        assertMasked("123456789",  at: 8, with: pattern, is: "+7(123)-456-78-9",  at: 15)
        assertMasked("1234567890", at: 9, with: pattern, is: "+7(123)-456-78-90", at: 16)
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
        
        assertMasked("1",    at: 0, with: pattern, is: "1",     at: 0)
        assertMasked("12",   at: 1, with: pattern, is: "12.",   at: 2)
        assertMasked("123",  at: 2, with: pattern, is: "12.3",  at: 3)
        assertMasked("1234", at: 3, with: pattern, is: "12.34", at: 4)
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
        
        assertMasked("1",      at: 0, with: pattern, is: "1",       at: 0)
        assertMasked("12",     at: 1, with: pattern, is: "12.",     at: 2)
        assertMasked("123",    at: 2, with: pattern, is: "12.3",    at: 3)
        assertMasked("1234",   at: 3, with: pattern, is: "12.34",   at: 4)
        assertMasked("12345",  at: 4, with: pattern, is: "12.345",  at: 5)
        assertMasked("123456", at: 5, with: pattern, is: "12.3456", at: 6)
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
        
        assertMasked("123",    at: 0, with: pattern, is: "123",    at: 0)
        assertMasked("123456", at: 3, with: pattern, is: "123456", at: 3)
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
        
        assertMasked("1",   at: 0, with: pattern, is: "AB1",    at: 2)
        assertMasked("12",  at: 1, with: pattern, is: "AB12",   at: 3)
        assertMasked("123", at: 2, with: pattern, is: "AB123C", at: 5)
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
        
        assertMasked("",   at: 0, with: pattern, is: "",         at: 0)
        assertMasked("1",  at: 0, with: pattern, is: "+7 ( ) -", at: 8)
        assertMasked("12", at: 1, with: pattern, is: "+7 ( ) -", at: 8)
    }
    
    func test_mask_edgeCases_withCursorPositions() {
        
        let pattern = "(__)-__"
        
        assertMasked("1",   at: 0, with: pattern, is: "(1",     at: 1)
        assertMasked("12",  at: 1, with: pattern, is: "(12)-",  at: 4)
        assertMasked("123", at: 2, with: pattern, is: "(12)-3", at: 5)
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
        return mask.applyMask(to: state)
    }
    
    private func assertMasked(
        _ text: String,
        at cursorPosition: Int? = nil,
        with pattern: String,
        is expectedText: String,
        at expectedCursor: Int? = nil,
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
