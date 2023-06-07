//
//  TextFieldStateDSLTests.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class TextFieldStateDSLTests: XCTestCase {
    
    let reducer = TransformingReducer(placeholderText: "A placeholder")
    
    // MARK: - insertAtCursor
    
    func test_insertAtCursor_empty_empty() throws {
        
        let state: TextFieldState = .editing(.empty)
        
        let action = try state.insert("")
        
        XCTAssertNoDiff(action, .changeText("", in: .init(location: 0, length: 0)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("", cursorAt: 0)))
    }
    
    func test_insertAtCursor_nonEmpty_empty() throws {
        
        let state: TextFieldState = .editing(.empty)
        
        let action = try state.insert("123")
        
        XCTAssertNoDiff(action, .changeText("123", in: .init(location: 0, length: 0)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("123", cursorAt: 3)))
    }
    
    func test_insertAtCursor_nonEmpty_nonEmpty_cursorAtZero() throws {
        
        let state: TextFieldState = .editing(.init("ab", cursorPosition: 0))
        
        let action = try state.insert("123")
        
        XCTAssertNoDiff(action, .changeText("123", in: .init(location: 0, length: 0)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("123ab", cursorAt: 3)))
    }
    
    func test_insertAtCursor_nonEmpty_nonEmpty_cursorAtOne() throws {
        
        let state: TextFieldState = .editing(.init("ab", cursorPosition: 1))
        
        let action = try state.insert("123")
        
        XCTAssertNoDiff(action, .changeText("123", in: .init(location: 1, length: 0)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("a123b", cursorAt: 4)))
    }
    
    func test_insertAtCursor_nonEmpty_nonEmpty_cursorAtTwo() throws {
        
        let state: TextFieldState = .editing(.init("ab", cursorPosition: 2))
        
        let action = try state.insert("123")
        
        XCTAssertNoDiff(action, .changeText("123", in: .init(location: 2, length: 0)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("ab123", cursorAt: 5)))
    }
    
    // MARK: - deleteBeforeCursor
    
    func test_deleteBeforeCursor_empty() throws {
        
        let state: TextFieldState = .editing(.empty)
        
        XCTAssertThrowsError(
            _ = try state.delete()
        ) {
            XCTAssertEqual(
                $0 as NSError,
                .init(domain: "Can't remove before cursor if cursor at start", code: 0))
        }
    }
    
    func test_deleteBeforeCursor_nonEmpty_cursorAtZero() throws {
        
        let state: TextFieldState = .editing(.init("ab", cursorPosition: 0))
        
        XCTAssertThrowsError(
            _ = try state.delete()
        ) {
            XCTAssertEqual(
                $0 as NSError,
                .init(domain: "Can't remove before cursor if cursor at start", code: 0))
        }
    }
    
    func test_deleteBeforeCursor_nonEmpty_cursorAtOne() throws {
        
        let state: TextFieldState = .editing(.init("ab", cursorPosition: 1))
        
        let action = try state.delete()
        
        XCTAssertNoDiff(action, .changeText("", in: .init(location: 0, length: 1)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("b", cursorAt: 0)))
    }
    
    func test_deleteBeforeCursor_nonEmpty_cursorAtTwo() throws {
        
        let state: TextFieldState = .editing(.init("ab", cursorPosition: 2))
        
        let action = try state.delete()
        
        XCTAssertNoDiff(action, .changeText("", in: .init(location: 1, length: 1)))
        
        let newState = try reducer.reduce(state, with: action)
        
        XCTAssertNoDiff(newState, .editing(.init("a", cursorAt: 1)))
    }
    
    // MARK: - removeLast
    
    func test_removeLast_shouldThrowOn_placeholder() throws {
        
        let state: TextFieldState = .placeholder("A placeholder")
        
        XCTAssertThrowsError(
            _ = try state.delete()
        ) {
            XCTAssertEqual(
                ($0 as NSError).domain,
                "Expected `editing` state, got placeholder(\"A placeholder\")"
            )
        }
    }
    
    func test_removeLast_shouldThrowOn_noFocus_empty() throws {
        
        let state: TextFieldState = .noFocus("")
        
        XCTAssertThrowsError(
            _ = try state.delete()
        ) {
            XCTAssertEqual(
                ($0 as NSError).domain,
                "Expected `editing` state, got noFocus(\"\")"
            )
        }
    }
    
    func test_removeLast_shouldThrowOn_noFocus_nonEmpty() throws {
        
        let state: TextFieldState = .noFocus("any text")
        
        XCTAssertThrowsError(
            _ = try state.delete()
        ) {
            XCTAssertEqual(
                ($0 as NSError).domain,
                "Expected `editing` state, got noFocus(\"any text\")"
            )
        }
    }
    
    func test_removeLast_shouldRemoveLast_editing() throws {
        
        let state: TextFieldState = .editing(.init("Abcde", cursorPosition: 2))
        
        let result = try reducer.reduce(
            state,
            actions: { try $0.removeLast() },
            { try $0.removeLast(3) },
            { try $0.removeLast() }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.init("Abcde", cursorAt: 2)),
            .editing(.init("Abcd", cursorAt: 4)),
            .editing(.init("A", cursorAt: 1)),
            .editing(.empty),
        ])
    }
    
    // MARK: - paste
    
    func test_paste_shouldThrowInPlaceholderState() {
        
        XCTAssertThrowsError(
            _ = try reducer.reduce(
                .placeholder("A placeholder"),
                actions: { try $0.paste("12345") }
            )
        ) {
            XCTAssertNoDiff($0 as NSError, NSError(domain: "Expected `editing` state, got placeholder(\"A placeholder\")", code: 0))
        }
    }
    
    func test_paste_shouldThrowInNoFocusState() {
        
        XCTAssertThrowsError(
            _ = try reducer.reduce(
                .noFocus("+2"),
                actions: { try $0.paste("12345") }
            )
        ) {
            XCTAssertNoDiff($0 as NSError, NSError(domain: "Expected `editing` state, got noFocus(\"+2\")", code: 0))
        }
    }
    
    func test_paste_shouldChangeTextStateInEditingState() throws {
        
        let paste = "12345"
        let result = try reducer.reduce(
            .editing(.init("Abc", cursorAt: 2)),
            actions: { try $0.paste(paste) }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.init("Abc", cursorAt: 2)),
            .editing(.init(paste, cursorAt: 5)),
        ])
    }
    
    // MARK: - replace
    
    func test_replace_shouldThrowInPlaceholderState() {
        
        XCTAssertThrowsError(
            _ = try reducer.reduce(
                .placeholder("A placeholder"),
                actions: { try $0.replace(count: 1, with: "12345") }
            )
        ) {
            XCTAssertNoDiff($0 as NSError, NSError(domain: "Expected `editing` state, got placeholder(\"A placeholder\")", code: 0))
        }
    }
    
    func test_replace_shouldThrowInNoFocusState() {
        
        XCTAssertThrowsError(
            _ = try reducer.reduce(
                .noFocus("+2"),
                actions: { try $0.replace(count: 1, with: "12345") }
            )
        ) {
            XCTAssertNoDiff($0 as NSError, NSError(domain: "Expected `editing` state, got noFocus(\"+2\")", code: 0))
        }
    }
    
    func test_replace_shouldThrowInEditingOnBasSelection() {
        
        XCTAssertThrowsError(
            _ = try reducer.reduce(
                .editing(.init("Abcde", cursorAt: 3)),
                actions: { try $0.replace(count: 3, with: "12345") }
            )
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 5), got: .init(location: 3, length: 3)))
        }
    }
    
    func test_replace_shouldChangeTextStateInEditingState() throws {
        
        let result = try reducer.reduce(
            .editing(.init("Abcde", cursorAt: 3)),
            actions: { try $0.replace(count: 2, with: "12345") }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.init("Abcde", cursorAt: 3)),
            .editing(.init("Abc12345", cursorAt: 8)),
        ])
    }
    
    func test_replace_shouldChangeTextStateInEditingState2() throws {
        
        let result = try reducer.reduce(
            .editing(.init("Abcde", cursorAt: 3)),
            actions: { try $0.replace(from: 1, count: 2, with: "12345") }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.init("Abcde", cursorAt: 3)),
            .editing(.init("A12345de", cursorAt: 6)),
        ])
    }
}
