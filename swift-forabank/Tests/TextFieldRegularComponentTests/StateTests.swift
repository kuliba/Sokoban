//
//  StateTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import TextFieldRegularComponent
import XCTest

final class StateTests: XCTestCase {

    typealias State = TextFieldRegularView.ViewModel.State

    // MARK: - isEditing
    
    func test_isEditing_shouldReturnFalse_onPlaceholder() {
        
        let state = State(placeholderText: "Placeholder")
        
        XCTAssertFalse(state.isEditing)
    }

    func test_isEditing_shouldReturnFalse_onNoFocus() {
        
        let state = State.noFocus("ABC")
        
        XCTAssertFalse(state.isEditing)
    }

    func test_isEditing_shouldReturnTrue_onFocus() {
        
        let state = State.focus(text: "ABC", cursorPosition: 2)
        
        XCTAssert(state.isEditing)
    }

    // MARK: - text
    
    func test_text_shouldReturnNil_onPlaceholder() {
        
        let state = State(placeholderText: "Placeholder")
        
        XCTAssertNil(state.text)
    }

    func test_text_shouldReturnNil_onNoFocus() {
        
        let state = State.noFocus("ABC")
        
        XCTAssertEqual(state.text, "ABC")
    }

    func test_text_shouldReturnTrue_onFocus() {
        
        let state = State.focus(text: "ABC", cursorPosition: 2)
        
        XCTAssertEqual(state.text, "ABC")
    }
    
    // MARK: - init
    
    func test_init_should_setToPlaceholder_onNilText() {
        
        let state = State(text: nil, placeholderText: "Placeholder")
        
        XCTAssertEqual(state, .placeholder("Placeholder"))
    }
    
    func test_init_should_setToPlaceholder_onEmptyText() {
        
        let state = State(text: "", placeholderText: "Placeholder")
        
        XCTAssertEqual(state, .placeholder("Placeholder"))
    }
    
    func test_init_should_setToNoFocus_onNonEmptyText_nilCursor() {
        
        let sState = State(text: "ABC", placeholderText: "Placeholder")
        
        XCTAssertEqual(sState, .noFocus("ABC"))
    }
    
    func test_init_should_setToNoFocus_onNonEmptyText_nonNilCursor() {
        
        let state = State(text: "ABC", cursorPosition: 2, placeholderText: "Placeholder")
        
        XCTAssertEqual(state, .focus(text: "ABC", cursorPosition: 2))
    }
}
