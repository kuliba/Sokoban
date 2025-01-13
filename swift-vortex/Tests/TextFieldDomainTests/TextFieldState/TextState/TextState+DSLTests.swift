//
//  TextStateDSLTests.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

@testable import TextFieldDomain
import XCTest

final class TextStateDSLTests: XCTestCase {
    
    // MARK: - view
    
    func test_view_empty_cursorAtNegative() {
        
        let state: TextState = .init("", cursorPosition: -1)
        
        XCTAssertNoDiff(state.parts, .init("", "", ""))
    }
    
    func test_view_empty_cursorAtZero() {
        
        let state: TextState = .empty
        
        XCTAssertNoDiff(state.parts, .init("", "", ""))
    }
    
    func test_view_empty_cursorAtMax() {
        
        let state: TextState = .init("", cursorPosition: 1)
        
        XCTAssertNoDiff(state.parts, .init("", "", ""))
    }
    
    func test_view_digit_cursorAtNegative() {
        
        let state: TextState = .init("1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.parts, .init("1", "1", ""))
    }
    
    func test_view_digit_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.parts, .init("1", "", "1"))
    }
    
    func test_view_digit_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertNoDiff(state.parts, .init("1", "1", ""))
    }
    
    func test_view_digit_cursorAtMax() {
        
        let state: TextState = .init("1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.parts, .init("1", "1", ""))
    }
    
    func test_view_letter_cursorAtNegative() {
        
        let state: TextState = .init("1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.parts, .init("1", "1", ""))
    }
    
    func test_view_letter_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.parts, .init("1", "", "1"))
    }
    
    func test_view_letter_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertNoDiff(state.parts, .init("1", "1", ""))
    }
    
    func test_view_letter_cursorAtMax() {
        
        let state: TextState = .init("1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.parts, .init("1", "1", ""))
    }
    
    func test_view_mix_cursorAtNegative() {
        
        let state: TextState = .init("a1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.parts, .init("a1", "a1", ""))
    }
    
    func test_view_mix_cursorAtZero() {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.parts, .init("a1", "", "a1"))
    }
    
    func test_view_mix_cursorAtOne() {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        XCTAssertNoDiff(state.parts, .init("a1", "a", "1"))
    }
    
    func test_view_mix_cursorAtTwo() {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.parts, .init("a1", "a1", ""))
    }
    
    func test_view_mix_cursorAtMax() {
        
        let state: TextState = .init("a1", cursorPosition: 3)
        
        XCTAssertNoDiff(state.parts, .init("a1", "a1", ""))
    }
    
    // MARK: - cursorIndex
    
    func test_cursorIndex_empty_cursorAtNegative() {
        
        let state: TextState = .init("", cursorPosition: -1)
        
        XCTAssertNoDiff(state.cursorPosition, 0)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 0)
    }
    
    func test_cursorIndex_empty_cursorAtZero() {
        
        let state: TextState = .empty
        
        XCTAssertNoDiff(state.cursorPosition, 0)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 0)
    }
    
    func test_cursorIndex_empty_cursorAtMax() {
        
        let state: TextState = .init("", cursorPosition: 1)
        
        XCTAssertNoDiff(state.cursorPosition, 0)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 0)
    }
    
    func test_cursorIndex_digit_cursorAtNegative() {
        
        let state: TextState = .init("1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_digit_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.cursorPosition, 0)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 0)
    }
    
    func test_cursorIndex_digit_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_digit_cursorAtMax() {
        
        let state: TextState = .init("1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_letter_cursorAtNegative() {
        
        let state: TextState = .init("1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_letter_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.cursorPosition, 0)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 0)
    }
    
    func test_cursorIndex_letter_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_letter_cursorAtMax() {
        
        let state: TextState = .init("1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_mix_cursorAtNegative() {
        
        let state: TextState = .init("a1", cursorPosition: -1)
        
        XCTAssertNoDiff(state.cursorPosition, 2)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 2)
    }
    
    func test_cursorIndex_mix_cursorAtZero() {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        XCTAssertNoDiff(state.cursorPosition, 0)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 0)
    }
    
    func test_cursorIndex_mix_cursorAtOne() {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        XCTAssertNoDiff(state.cursorPosition, 1)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 1)
    }
    
    func test_cursorIndex_mix_cursorAtTwo() {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        XCTAssertNoDiff(state.cursorPosition, 2)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 2)
    }
    
    func test_cursorIndex_mix_cursorAtMax() {
        
        let state: TextState = .init("a1", cursorPosition: 3)
        
        XCTAssertNoDiff(state.cursorPosition, 2)
        XCTAssertNoDiff(state.cursorIndex.utf16Offset(in: state.text), 2)
    }
    
    // MARK: - moveCursorLeft
    
    func test_moveCursorLeft_empty() {
        
        let state: TextState = .empty
        
        let result = state.moveCursorLeft()
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_moveCursorLeft_digit_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = state.moveCursorLeft()
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_moveCursorLeft_digit_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = state.moveCursorLeft()
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_moveCursorLeft_mix_cursorAtZero() {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = state.moveCursorLeft()
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("a1", "", "a1"))
    }
    
    func test_moveCursorLeft_mix_cursorAtOne() {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = state.moveCursorLeft()
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("a1", "", "a1"))
    }
    
    func test_moveCursorLeft_mix_cursorAtTwo() {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        let result = state.moveCursorLeft()
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a1", "a", "1"))
    }
    
    // MARK: - moveCursorRight
    
    func test_moveCursorRight_empty() {
        
        let state: TextState = .empty
        
        let result = state.moveCursorRight()
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_moveCursorRight_digit_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = state.moveCursorRight()
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("1", "1", ""))
    }
    
    func test_moveCursorRight_digit_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = state.moveCursorRight()
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("1", "1", ""))
    }
    
    func test_moveCursorRight_mix_cursorAtZero() {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = state.moveCursorRight()
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a1", "a", "1"))
    }
    
    func test_moveCursorRight_mix_cursorAtOne() {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = state.moveCursorRight()
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("a1", "a1", ""))
    }
    
    func test_moveCursorRight_mix_cursorAtTwo() {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        let result = state.moveCursorRight()
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("a1", "a1", ""))
    }
    
    // MARK: - insertAtCursor
    
    func test_insertAtCursor_empty_empty() {
        
        let state: TextState = .empty
        
        let result = state.insertAtCursor("")
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_insertAtCursor_nonEmpty_empty() {
        
        let state: TextState = .empty
        
        let result = state.insertAtCursor("EF")
        
        XCTAssertNoDiff(result.view, .init("EF", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("EF", "EF", ""))
    }
    
    func test_insertAtCursor_empty_digit_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = state.insertAtCursor("")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_insertAtCursor_nonEmpty_digit_cursorAtZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = state.insertAtCursor("EF")
        
        XCTAssertNoDiff(result.view, .init("EF1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("EF1", "EF", "1"))
    }
    
    func test_insertAtCursor_empty_digit_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = state.insertAtCursor("")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("1", "1", ""))
    }
    
    func test_insertAtCursor_nonEmpty_digit_cursorAtOne() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = state.insertAtCursor("EF")
        
        XCTAssertNoDiff(result.view, .init("1EF", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("1EF", "1EF", ""))
    }
    
    func test_insertAtCursor_empty_mix_cursorAtZero() {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = state.insertAtCursor("")
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("a1", "", "a1"))
    }
    
    func test_insertAtCursor_nonEmpty_mix_cursorAtZero() {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = state.insertAtCursor("EF")
        
        XCTAssertNoDiff(result.view, .init("EFa1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("EFa1", "EF", "a1"))
    }
    
    func test_insertAtCursor_empty_mix_cursorAtOne() {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = state.insertAtCursor("")
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a1", "a", "1"))
    }
    
    func test_insertAtCursor_nonEmpty_mix_cursorAtOne() {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = state.insertAtCursor("EF")
        
        XCTAssertNoDiff(result.view, .init("aEF1", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("aEF1", "aEF", "1"))
    }
    
    func test_insertAtCursor_empty_mix_cursorAtTwo() {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        let result = state.insertAtCursor("")
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("a1", "a1", ""))
    }
    
    func test_insertAtCursor_nonEmpty_mix_cursorAtTwo() {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        let result = state.insertAtCursor("EF")
        
        XCTAssertNoDiff(result.view, .init("a1EF", cursorAt: 4))
        XCTAssertNoDiff(result.parts, .init("a1EF", "a1EF", ""))
    }
    
    // MARK: - replaceSelected
    
    func test_replaceSelected_empty_zeroSelection_empty() throws {
        
        let state: TextState = .empty
        
        let result = try state.replaceSelected(count: 0, with: "")
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_replaceSelected_empty_nonZeroSelection_empty() throws {
        
        let state: TextState = .empty
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 1, with: "")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 0), got: .init(location: 0, length: 1)))
        }
    }
    
    func test_replaceSelected_empty_nonZeroSelection_nonEmpty() throws {
        
        let state: TextState = .empty
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 1, with: "EF")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 0), got: .init(location: 0, length: 1)))
        }
    }
    
    func test_replaceSelected_empty_nonZeroSelection_nonEmpty2() throws {
        
        let state: TextState = .empty
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 2, with: "EFG")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 0), got: .init(location: 0, length: 2)))
        }
    }
    
    func test_replaceSelected_digit_cursorAtZero_zeroSelection_empty() throws {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 0, with: "")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_replaceSelected_digit_cursorAtZero_nonZeroSelection_empty() throws {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 1, with: "")
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_replaceSelected_digit_cursorAtZero_nonZeroSelection_nonEmpty() throws {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 1, with: "EF")
        
        XCTAssertNoDiff(result.view, .init("EF", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("EF", "EF", ""))
    }
    
    func test_replaceSelected_digit_cursorAtZero_nonZeroSelection_nonEmpty2() throws {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 2, with: "EFG")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 1), got: .init(location: 0, length: 2)))
        }
    }
    
    func test_replaceSelected_digit_cursorAtOne_zeroSelection_empty() throws {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = try state.replaceSelected(count: 0, with: "")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("1", "1", ""))
    }
    
    func test_replaceSelected_digit_cursorAtOne_nonZeroSelection_empty() throws {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 1, with: "")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 1), got: .init(location: 1, length: 1)))
        }
    }
    
    func test_replaceSelected_digit_cursorAtOne_nonZeroSelection_nonEmpty() throws {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 1, with: "EF")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 1), got: .init(location: 1, length: 1)))
        }
    }
    
    func test_replaceSelected_digit_cursorAtOne_nonZeroSelection_nonEmpty2() throws {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 2, with: "EFG")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 1), got: .init(location: 1, length: 2)))
        }
    }
    
    func test_replaceSelected_mix_cursorAtZero_zeroSelection_empty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 0, with: "")
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("a1", "", "a1"))
    }
    
    func test_replaceSelected_mix_cursorAtZero_nonZeroSelection_empty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 1, with: "")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_replaceSelected_mix_cursorAtZero_nonZeroSelection_nonEmpty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 1, with: "EF")
        
        XCTAssertNoDiff(result.view, .init("EF1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("EF1", "EF", "1"))
    }
    
    func test_replaceSelected_mix_cursorAtZero_nonZeroSelection_nonEmpty2() throws {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        let result = try state.replaceSelected(count: 2, with: "EFG")
        
        XCTAssertNoDiff(result.view, .init("EFG", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("EFG", "EFG", ""))
    }
    
    func test_replaceSelected_mix_cursorAtOne_zeroSelection_empty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = try state.replaceSelected(count: 0, with: "")
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a1", "a", "1"))
    }
    
    func test_replaceSelected_mix_cursorAtOne_nonZeroSelection_empty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = try state.replaceSelected(count: 1, with: "")
        
        XCTAssertNoDiff(result.view, .init("a", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a", "a", ""))
    }
    
    func test_replaceSelected_mix_cursorAtOne_nonZeroSelection_nonEmpty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = try state.replaceSelected(count: 1, with: "EF")
        
        XCTAssertNoDiff(result.view, .init("aEF", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("aEF", "aEF", ""))
    }
    
    func test_replaceSelected_mix_cursorAtOne_nonZeroSelection_nonEmpty2() throws {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 2, with: "EFG")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 2), got: .init(location: 1, length: 2)))
        }
    }
    
    func test_replaceSelected_mix_cursorAtTwo_zeroSelection_empty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        let result = try state.replaceSelected(count: 0, with: "")
        
        XCTAssertNoDiff(result.view, .init("a1", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("a1", "a1", ""))
    }
    
    func test_replaceSelected_mix_cursorAtTwo_nonZeroSelection_empty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 1, with: "")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 2), got: .init(location: 2, length: 1)))
        }
    }
    
    func test_replaceSelected_mix_cursorAtTwo_nonZeroSelection_nonEmpty() throws {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 1, with: "EF")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 2), got: .init(location:2, length: 1)))
        }
    }
    
    func test_replaceSelected_mix_cursorAtTwo_nonZeroSelection_nonEmpty2() throws {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        XCTAssertThrowsError(
            _ = try state.replaceSelected(count: 2, with: "EFG")
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 2), got: .init(location: 2, length: 2)))
        }
    }
    
    // MARK: - deleteBeforeCursor
    
    func test_deleteBeforeCursor_empty() throws {
        
        let state: TextState = .empty
        
        XCTAssertThrowsError(
            _ = try state.deleteBeforeCursor()
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 0), got: .init(location: -1, length: 1)))
        }
    }
    
    func test_deleteBeforeCursor_digit_cursorAtZero() throws {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        XCTAssertThrowsError(
            _ = try state.deleteBeforeCursor()
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 1), got: .init(location: -1, length: 1)))
        }
    }
    
    func test_deleteBeforeCursor_digit_cursorAtOne() throws {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = try state.deleteBeforeCursor()
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_deleteBeforeCursor_mix_cursorAtZero() throws {
        
        let state: TextState = .init("a1", cursorPosition: 0)
        
        XCTAssertThrowsError(
            _ = try state.deleteBeforeCursor()
        ) {
            XCTAssertNoDiff($0 as? TextState.TextStateError, .invalidReplacementRange(expectedWithin: .init(location: 0, length: 2), got: .init(location: -1, length: 1)))
        }
    }
    
    func test_deleteBeforeCursor_mix_cursorAtOne() throws {
        
        let state: TextState = .init("a1", cursorPosition: 1)
        
        let result = try state.deleteBeforeCursor()
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_deleteBeforeCursor_mix_cursorAtTwo() throws {
        
        let state: TextState = .init("a1", cursorPosition: 2)
        
        let result = try state.deleteBeforeCursor()
        
        XCTAssertNoDiff(result.view, .init("a", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a", "a", ""))
    }
    
    // MARK: - reduce actions
    
    func test_reduce_identity_empty() throws {
        
        let state: TextState = .empty
        
        let result = try state.reduce(actions: { $0 }, { $0 })
        
        XCTAssertNoDiff(result.map(\.view), [
            .init("", cursorAt: 0),
            .init("", cursorAt: 0),
            .init("", cursorAt: 0)
        ])
    }
    
    func test_reduce_identity_noEmpty() throws {
        
        let state: TextState = .init("Abc", cursorPosition: 1)
        
        let result = try state.reduce(actions: { $0 }, { $0 })
        
        XCTAssertNoDiff(result.map(\.view), [
            .init("Abc", cursorAt: 1),
            .init("Abc", cursorAt: 1),
            .init("Abc", cursorAt: 1)
        ])
    }
    
    // MARK: - append
    
    func test_append_empty_to_empty() {
        
        let state: TextState = .empty
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("", "", ""))
    }
    
    func test_append_empty_to_digit_cursorPositionZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("1", "", "1"))
    }
    
    func test_append_empty_to_digit_cursorPositionEnd() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("1", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("1", "1", ""))
    }
    
    func test_append_empty_to_letter_cursorPositionZero() {
        
        let state: TextState = .init("a", cursorPosition: 0)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("a", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("a", "", "a"))
    }
    
    func test_append_empty_to_letter_cursorPositionEnd() {
        
        let state: TextState = .init("a", cursorPosition: 1)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("a", cursorAt: 1))
        XCTAssertNoDiff(result.parts, .init("a", "a", ""))
    }
    
    func test_append_empty_to_text_cursorPositionZero() {
        
        let state: TextState = .init("Abcd", cursorPosition: 0)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("Abcd", cursorAt: 0))
        XCTAssertNoDiff(result.parts, .init("Abcd", "", "Abcd"))
    }
    
    func test_append_empty_to_text_cursorPositionEnd() {
        
        let state: TextState = .init("Abcd", cursorPosition: 4)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("Abcd", cursorAt: 4))
        XCTAssertNoDiff(result.parts, .init("Abcd", "Abcd", ""))
    }
    
    func test_append_empty_to_text_cursorPositionMiddle() {
        
        let state: TextState = .init("Abcd", cursorPosition: 2)
        
        let result = state.append("")
        
        XCTAssertNoDiff(result.view, .init("Abcd", cursorAt: 2))
        XCTAssertNoDiff(result.parts, .init("Abcd", "Ab", "cd"))
    }
    
    func test_append_nonEmpty_to_empty() {
        
        let state: TextState = .empty
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("EFD", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("EFD", "EFD", ""))
    }
    
    func test_append_nonEmpty_to_digit_cursorPositionZero() {
        
        let state: TextState = .init("1", cursorPosition: 0)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("EFD1", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("EFD1", "EFD", "1"))
    }
    
    func test_append_nonEmpty_to_digit_cursorPositionEnd() {
        
        let state: TextState = .init("1", cursorPosition: 1)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("1EFD", cursorAt: 4))
        XCTAssertNoDiff(result.parts, .init("1EFD", "1EFD", ""))
    }
    
    func test_append_nonEmpty_to_letter_cursorPositionZero() {
        
        let state: TextState = .init("a", cursorPosition: 0)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("EFDa", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("EFDa", "EFD", "a"))
    }
    
    func test_append_nonEmpty_to_letter_cursorPositionEnd() {
        
        let state: TextState = .init("a", cursorPosition: 1)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("aEFD", cursorAt: 4))
        XCTAssertNoDiff(result.parts, .init("aEFD", "aEFD", ""))
    }
    
    func test_append_nonEmpty_to_text_cursorPositionZero() {
        
        let state: TextState = .init("Abcd", cursorPosition: 0)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("EFDAbcd", cursorAt: 3))
        XCTAssertNoDiff(result.parts, .init("EFDAbcd", "EFD", "Abcd"))
    }
    
    func test_append_nonEmpty_to_text_cursorPositionEnd() {
        
        let state: TextState = .init("Abcd", cursorPosition: 4)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("AbcdEFD", cursorAt: 7))
        XCTAssertNoDiff(result.parts, .init("AbcdEFD", "AbcdEFD", ""))
    }
    
    func test_append_nonEmpty_to_text_cursorPositionMiddle() {
        
        let state: TextState = .init("Abcd", cursorPosition: 2)
        
        let result = state.append("EFD")
        
        XCTAssertNoDiff(result.view, .init("AbEFDcd", cursorAt: 5))
        XCTAssertNoDiff(result.parts, .init("AbEFDcd", "AbEFD", "cd"))
    }
    
    // MARK: - removeLast
    
    func test_removeLast_negative_from_empty_shouldThrow() throws {
        
        let state: TextState = .empty
        
        XCTAssertThrowsError(
            _ = try state.removeLast(-1)
        ) {
            XCTAssertEqual(($0 as NSError).domain, "Cannot remove negative number of characters from text.")
        }
    }
    
    func test_removeLast_positive_from_empty_shouldThrow() throws {
        
        let state: TextState = .empty
        
        XCTAssertThrowsError(
            _ = try state.removeLast(1)
        ) {
            XCTAssertEqual(($0 as NSError).domain, "Cannot remove 1 character(s) - have only 0")
        }
    }
    
    func test_removeLast_zero_from_empty_shouldReturnEmpty() throws {
        
        let state: TextState = .empty
        
        let result = try state.removeLast(0)
        
        XCTAssertNoDiff(result, .empty)
    }
    
    func test_removeLast_negative_from_nonEmpty_shouldThrow() throws {
        
        let state: TextState = .init("Abcde", cursorPosition: 2)
        
        XCTAssertThrowsError(
            _ = try state.removeLast(-1)
        ) {
            XCTAssertEqual(($0 as NSError).domain, "Cannot remove negative number of characters from text.")
        }
    }
    
    func test_removeLast_tooBig_from_nonEmpty_shouldThrow() throws {
        
        let state: TextState = .init("Abcde", cursorPosition: 2)
        
        XCTAssertThrowsError(
            _ = try state.removeLast(6)
        ) {
            XCTAssertEqual(($0 as NSError).domain, "Cannot remove 6 character(s) - have only 5")
            XCTAssertGreaterThan(6, "Abcde".count)
        }
    }
    
    func test_removeLast_zero_from_nonEmpty_shouldReturnSame() throws {
        
        let state: TextState = .init("Abcde", cursorPosition: 2)
        
        let result = try state.removeLast(0)
        
        XCTAssertNoDiff(result, state)
        XCTAssertNoDiff(result.parts, .init("Abcde", "Ab", "cde"))
    }
    
    func test_removeLast_one_from_nonEmpty() throws {
        
        let state: TextState = .init("Abcde", cursorPosition: 2)
        
        let result = try state.removeLast(1)
        
        XCTAssertNoDiff(result, .init("Abcd", cursorPosition: 4))
        XCTAssertNoDiff(result.parts, .init("Abcd", "Abcd", ""))
    }
    
    func test_removeLast_two_from_nonEmpty() throws {
        
        let state: TextState = .init("Abcde", cursorPosition: 2)
        
        let result = try state.removeLast(2)
        
        XCTAssertNoDiff(result, .init("Abc", cursorPosition: 3))
        XCTAssertNoDiff(result.parts, .init("Abc", "Abc", ""))
    }
    
    func test_removeLast_all_from_nonEmpty_shouldReturnEmpty() throws {
        
        let state: TextState = .init("Abcde", cursorPosition: 2)
        
        let result = try state.removeLast(5)
        
        XCTAssertNoDiff(result, .empty)
        XCTAssertNoDiff(5, "Abcde".count)
    }
}
