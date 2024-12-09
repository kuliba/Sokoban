//
//  TextFieldStateTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

@testable import Vortex
@testable import TextFieldComponent
import XCTest

final class TextFieldStateTests: XCTestCase {
    
    func test_init_withString_shouldSetToPlaceholder() {
        
        let text = "Any text"
        let state = TextFieldState(text)
        
        XCTAssertNoDiff(state, .placeholder(text))
    }
    
    // MARK: - isEditing
    
    func test_isEditing_shouldReturnFalse_onPlaceholder() {
        
        let state: TextFieldState = .placeholder("Placeholder")
        
        XCTAssertFalse(state.isEditing)
    }

    func test_isEditing_shouldReturnFalse_onNoFocus() {
        
        let state: TextFieldState = .noFocus("ABC")
        
        XCTAssertFalse(state.isEditing)
    }

    func test_isEditing_shouldReturnTrue_onFocus() {
        
        let state: TextFieldState = .editing(.init("ABC", cursorPosition: 2))
        
        XCTAssert(state.isEditing)
    }

    // MARK: - text
    
    func test_text_shouldReturnNil_onPlaceholder() {
        
        let state: TextFieldState = .placeholder("Placeholder")

        XCTAssertNil(state.text)
    }

    func test_text_shouldReturnNil_onNoFocus() {
        
        let state: TextFieldState = .noFocus("ABC")
        
        XCTAssertNoDiff(state.text, "ABC")
    }

    func test_text_shouldReturnTrue_onFocus() {
        
        let state: TextFieldState = .editing(.init("ABC", cursorPosition: 2))
        
        XCTAssertNoDiff(state.text, "ABC")
    }
    
    // MARK: - makeTextFieldState
    
    func test_makeTextFieldState_should_setToPlaceholder_onNilText() {
        
        let state: TextFieldState = .makeTextFieldState(text: nil, placeholderText: "Placeholder")
        
        XCTAssertNoDiff(state, .placeholder("Placeholder"))
    }
    
    func test_makeTextFieldState_should_setToPlaceholder_onEmptyText() {
        
        let state: TextFieldState = .makeTextFieldState(text: "", placeholderText: "Placeholder")
        
        XCTAssertNoDiff(state, .placeholder("Placeholder"))
    }
    
    func test_makeTextFieldState_should_setToNoFocus_onNonEmptyText_nilCursor() {
        
        let state: TextFieldState = .makeTextFieldState(text: "ABC", placeholderText: "Placeholder")
        
        XCTAssertEqual(state, .noFocus("ABC"))
    }
    
    func test_makeTextFieldState_should_setToNoFocus_onNonEmptyText_nonNilCursor() {
        
        let state: TextFieldState = .makeTextFieldState(text: "ABC", cursorPosition: 2, placeholderText: "Placeholder")
        
        XCTAssertEqual(state, .editing(.init("ABC", cursorAt: 2)))
    }
}
