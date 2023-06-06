//
//  TextStateTests.swift
//  
//
//  Created by Igor Malyarov on 17.05.2023.
//

@testable import TextFieldDomain
import XCTest

final class TextStateTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_forEmptyTextShouldSetCursorPositionToZero() {
        
        let state = TextState("")
        
        XCTAssertNoDiff(state.text, "")
        XCTAssertNoDiff(state.cursorPosition, 0)
    }
    
    func test_init_forTextOfOneShouldSetCursorPositionToOne() {
        
        let state = TextState("a")
        
        XCTAssertNoDiff(state.text, "a")
        XCTAssertNoDiff(state.cursorPosition, 1)
    }
    
    func test_init_forNonEmptyTextShouldSetCursorPositionToEnd() {
        
        let state = TextState("abc")
        
        XCTAssertNoDiff(state.text, "abc")
        XCTAssertNoDiff(state.cursorPosition, 3)
        XCTAssertNoDiff(state.cursorPosition, state.text.count)
    }
    
    func test_init_forEmptyTextShouldSetCursorPositionToZero_onZero() {
        
        let state = TextState("", cursorPosition: 0)
        
        XCTAssertNoDiff(state.text, "")
        XCTAssertNoDiff(state.cursorPosition, 0)
    }
    
    func test_init_forEmptyTextShouldSetCursorPositionToZero_onNegative() {
        
        let state = TextState("", cursorPosition: -1)
        
        XCTAssertNoDiff(state.text, "")
        XCTAssertNoDiff(state.cursorPosition, 0)
    }
    
    func test_init_forEmptyTextShouldSetCursorPositionToZero_onPositive() {
        
        let state = TextState("", cursorPosition: 1)
        
        XCTAssertNoDiff(state.text, "")
        XCTAssertNoDiff(state.cursorPosition, 0)
    }
    
    func test_init_forTextOfOneShouldSetCursorPositionToEnd_onNegative() {
        
        let state = TextState("1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.text, "1")
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorPosition, state.text.count)
    }
    
    func test_init_forNonEmptyTextShouldSetCursorPositionToEnd_onNegative() {
        
        let state = TextState("abc", cursorPosition: -1)
        
        XCTAssertNoDiff(state.text, "abc")
        XCTAssertNoDiff(state.cursorPosition, 3)
        XCTAssertNoDiff(state.cursorPosition, state.text.count)
    }
    
    func test_init_forTextOfOneShouldSetCursorPositionToZero_onZero() {
        
        let state = TextState("1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.text, "1")
        XCTAssertNoDiff(state.cursorPosition, 0)
    }
    
    func test_init_forNonEmptyTextShouldSetCursorPositionToZero_onZero() {
        
        let state = TextState("abc", cursorPosition: 0)
        
        XCTAssertNoDiff(state.text, "abc")
        XCTAssertNoDiff(state.cursorPosition, 0)
    }
    
    func test_init_forTextOfOneShouldSetCursorPositionToEnd_onTooBig() {
        
        let state = TextState("1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.text, "1")
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorPosition, state.text.count)
    }
    
    func test_init_forNonEmptyTextShouldSetCursorPositionToEnd_onTooBig() {
        
        let state = TextState("abc", cursorPosition: 4)
        
        XCTAssertNoDiff(state.text, "abc")
        XCTAssertNoDiff(state.cursorPosition, 3)
        XCTAssertNoDiff(state.cursorPosition, state.text.count)
    }
    
    // MARK: - replace in range
    
    func test_replace_shouldThrow_onNegativeLocationRange() {
        
        let state = TextState("abc", cursorPosition: 2)
        let illegalRange = NSRange(location: -1, length: 0)
        
        XCTAssertThrowsError(
            _ = try state.replace(inRange: illegalRange, with: "any")
        ) { error in
            XCTAssertNoDiff(
                error as? TextState.TextStateError,
                .invalidReplacementRange(expectedWithin: .init(location: 0, length: 3), got: illegalRange)
            )
        }
    }
    
    func test_replace_shouldReturnChangedTextState_onValidRange() throws {
        
        let state = TextState("abc", cursorPosition: 2)
        let range = NSRange(location: 0, length: 0)
        
        let replaced = try state.replace(inRange: range, with: "XYZ")
        
        XCTAssertNoDiff(replaced.view, .init("XYZabc", cursorAt: 3))
    }
    
    func test_replace_shouldReturnChangedTextState_onValidRange2() throws {
        
        let state = TextState("abc", cursorPosition: 2)
        let range = NSRange(location: 1, length: 1)
        
        let replaced = try state.replace(inRange: range, with: "XYZ")
        
        XCTAssertNoDiff(replaced.view, .init("aXYZc", cursorAt: 4))
    }
    
    func test_replace_shouldReturnChangedTextState_onValidRange3() throws {
        
        let state = TextState("abc", cursorPosition: 2)
        let range = NSRange(location: 1, length: 2)
        
        let replaced = try state.replace(inRange: range, with: "XYZ")
        
        XCTAssertNoDiff(replaced.view, .init("aXYZ", cursorAt: 4))
    }
    
    func test_replace_shouldReturnChangedTextState_onValidRange4() throws {
        
        let state = TextState("abc", cursorPosition: 2)
        let range = NSRange(location: 0, length: 3)
        
        let replaced = try state.replace(inRange: range, with: "XYZ")
        
        XCTAssertNoDiff(replaced.view, .init("XYZ", cursorAt: 3))
    }

    // MARK: - reduce series of actions
    
    func test_reduce_seriesOfActions() throws {
        
        let state: TextState = .empty
        
        let result = try state.reduce(
            actions: { $0.insertAtCursor("3") },
            { $0.insertAtCursor("49") },
            { $0.moveCursorLeft() },
            { try $0.deleteBeforeCursor() }
        )
        
        XCTAssertNoDiff(result.map(\.view), [
            .init("",    cursorAt: 0),
            .init("3",   cursorAt: 1),
            .init("349", cursorAt: 3),
            .init("349", cursorAt: 2),
            .init("39",  cursorAt: 1),
        ])
    }
}

final class NSRangeIsValidForReplacementTests: XCTestCase {
    
    func test_isValidForReplacement() {
        
        XCTAssertFalse(isValidForReplacement(location: -1, length: 0))
        XCTAssertFalse(isValidForReplacement(location: 0, length: -1))
        XCTAssertFalse(isValidForReplacement(location: 5, length: -1))
        
        XCTAssertFalse(isValidForReplacement(location: 0, length: 6))
        XCTAssertFalse(isValidForReplacement(location: 1, length: 5))
        XCTAssertFalse(isValidForReplacement(location: 3, length: 3))
        XCTAssertFalse(isValidForReplacement(location: 5, length: 1))
        XCTAssertFalse(isValidForReplacement(location: 6, length: 0))
        
        XCTAssertTrue(isValidForReplacement(location: 0, length: 5))
        XCTAssertTrue(isValidForReplacement(location: 1, length: 4))
        XCTAssertTrue(isValidForReplacement(location: 1, length: 3))
        XCTAssertTrue(isValidForReplacement(location: 1, length: 0))
        XCTAssertTrue(isValidForReplacement(location: 3, length: 2))
        XCTAssertTrue(isValidForReplacement(location: 4, length: 0))
        XCTAssertTrue(isValidForReplacement(location: 4, length: 1))
        XCTAssertTrue(isValidForReplacement(location: 5, length: 0))
    }
    
    // MARK: - Helpers
    
    private func isValidForReplacement(location: Int, length: Int) -> Bool {
        
        let range = NSRange(location: location, length: length)
        return range.isValidForReplacement(in: "abcde")
    }
}
