//
//  ReducerTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

@testable import TextFieldRegularComponent
import SwiftUI
import XCTest

final class ReducerTests: XCTestCase {
    
    // MARK: - textViewDidBeginEditing
    
    func test_reduce_shouldReturnEmptyFocusState_fromPlaceholder_onDidBeginEditing() {
        
        assertReduce(
            state: .placeholder("Placeholder"),
            with: .textViewDidBeginEditing,
            returns: .focus(text: "", cursorPosition: 0)
        )
    }
    
    func test_reduce_shouldReturnFocusWithText_fromNoFocusWithNonEmptyText_onDidBeginEditing() {
        
        assertReduce(
            state: .noFocus("123456"),
            with: .textViewDidBeginEditing,
            returns: .focus(text: "123456", cursorPosition: 6)
        )
    }
    
    // MARK: - textViewDidEndEditing
    
    func test_reduce_shouldReturnPlaceholder_fromFocusWithEmptyText_onDidEndEditing() {
        
        assertReduce(
            state: .focus(text: "", cursorPosition: 0),
            with: .textViewDidEndEditing,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_shouldReturnNoFocusWithText_fromFocusWithNonEmptyText_onDidEndEditing() {
        
        assertReduce(
            state: .focus(text: "123456", cursorPosition: 0),
            with: .textViewDidEndEditing,
            returns: .noFocus("123456")
        )
    }
    
    // MARK: - shouldChangeTextIn
    
    func test_reduce_shouldReturnFocusWithChangedText_fromFocus_onShouldChangeTextIn() {
        
        assertReduce(
            state: .focus(text: "123456", cursorPosition: 6),
            with: .shouldChangeTextIn(.init(location: 3, length: 0), "ABC"),
            returns: .focus(text: "123ABC456", cursorPosition: 6)
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldNotAppendExtraText_onLengthEqualLimit_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 5)
        
        assertReduce(
            state: .focus(text: "12345", cursorPosition: 5),
            with: .shouldChangeTextIn(.init(location: 5, length: 0), "ABC"),
            reducer: reducer,
            returns: .focus(text: "12345", cursorPosition: 5)
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldAppendPartOfExtraText_onLengthLessThanLimit_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 6)
        
        assertReduce(
            state: .focus(text: "12345", cursorPosition: 5),
            with: .shouldChangeTextIn(.init(location: 5, length: 0), "ABC"),
            reducer: reducer,
            returns: .focus(text: "12345A", cursorPosition: 6)
        )
    }
    
    // MARK: - setTextTo
    
    func test_reduce_shouldChangeStateToPlaceholderFromNoFocus_onSetTextTo_nilText() {
        
        assertReduce(
            state: .noFocus("123456"),
            with: .setTextTo(nil),
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_shouldChangeStateToPlaceholderFromFocus_onSetTextTo_nilText() {
        
        assertReduce(
            state: .focus(text: "123456", cursorPosition: 6),
            with: .setTextTo(nil),
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_shouldChangeTextInNoFocus_onSetTextTo_nonNilText() {
        
        assertReduce(
            state: .noFocus("123456"),
            with: .setTextTo("ABC"),
            returns: .noFocus("ABC")
        )
    }
    
    func test_reduce_shouldChangeTextInFocus_onSetTextTo_nonNilText() {
        
        assertReduce(
            state: .focus(text: "123456", cursorPosition: 6),
            with: .setTextTo("ABC"),
            returns: .focus(text: "ABC", cursorPosition: 3)
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeStateToPlaceholderFromNoFocus_onSetTextTo_nilText() {
        
        let reducer = makeReducer(limit: 3)
        
        assertReduce(
            state: .noFocus("123456"),
            with: .setTextTo(nil),
            reducer: reducer,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeStateToPlaceholderFromFocus_onSetTextTo_nilText() {
        
        let reducer = makeReducer(limit: 3)
        
        assertReduce(
            state: .focus(text: "123456", cursorPosition: 6),
            with: .setTextTo(nil),
            reducer: reducer,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeTextInNoFocus_onSetTextTo_nonNilText() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .noFocus("12"),
            with: .setTextTo("ABC"),
            reducer: reducer,
            returns: .noFocus("AB")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeTextInFocus_onSetTextTo_nonNilText() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .focus(text: "12", cursorPosition: 1),
            with: .setTextTo("ABC"),
            reducer: reducer,
            returns: .focus(text: "AB", cursorPosition: 2)
        )
    }
    
    // MARK: - Edge Cases
    
    func test_reduce_withTransformLimitingLength_shouldNotChangeStateInPlaceholder_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .placeholder("Placeholder"),
            with: .shouldChangeTextIn(.init(location: 1, length: 1), "ABC"),
            reducer: reducer,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldNotChangeStateInPlaceholder_onSetTextTo() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .placeholder("Placeholder"),
            with: .setTextTo("ABC"),
            reducer: reducer,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldNotChangeStateInPlaceholder_onTextViewDidEndEditing() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .placeholder("Placeholder"),
            with: .textViewDidEndEditing,
            reducer: reducer,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldNotChangeState_onTextViewDidBeginEditing() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .focus(text: "12", cursorPosition: 1),
            with: .textViewDidBeginEditing,
            reducer: reducer,
            returns: .focus(text: "12", cursorPosition: 1)
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeTextInFocusState_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .focus(text: "12", cursorPosition: 1),
            with: .shouldChangeTextIn(.init(location: 1, length: 1), "ABC"),
            reducer: reducer,
            returns: .focus(text: "1A", cursorPosition: 2)
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldNotChangeNoFocusWithState_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .noFocus("1234567"),
            with: .shouldChangeTextIn(.init(location: 1, length: 1), "ABC"),
            reducer: reducer,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldNotChangeNoFocusWithEmptyTextState_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .noFocus(""),
            with: .shouldChangeTextIn(.init(location: 1, length: 1), "ABC"),
            reducer: reducer,
            returns: .noFocus("")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeTextInFocus_onShouldChangeTextIn() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .focus(text: "12", cursorPosition: 1),
            with: .shouldChangeTextIn(.init(location: 1, length: 1), "ABC"),
            reducer: reducer,
            returns: .focus(text: "1A", cursorPosition: 2)
        )
    }
    
    func test_reduce_shouldChangeTextInNoFocus_onTextViewDidEndEditing() {
        
        assertReduce(
            state: .noFocus("1234567"),
            with: .textViewDidEndEditing,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeTextInNoFocus_onTextViewDidEndEditing() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .noFocus("1234567"),
            with: .textViewDidEndEditing,
            reducer: reducer,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_shouldChangeStateToNoFocus_onTextViewDidEndEditing() {
        
        assertReduce(
            state: .focus(text: "1234567", cursorPosition: 5),
            with: .textViewDidEndEditing,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeStateToNoFocus_onTextViewDidEndEditing() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .focus(text: "1234567", cursorPosition: 5),
            with: .textViewDidEndEditing,
            reducer: reducer,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_shouldChangeStateToPlaceholder_onEmpty_onTextViewDidEndEditing() {
        
        assertReduce(
            state: .focus(text: "", cursorPosition: 0),
            with: .textViewDidEndEditing,
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeStateToPlaceholder_onEmpty_onTextViewDidEndEditing() {
        
        let reducer = makeReducer(limit: 2)
        
        assertReduce(
            state: .focus(text: "", cursorPosition: 0),
            with: .textViewDidEndEditing,
            reducer: reducer,
            returns: .placeholder("Placeholder")
        )
    }
    
    // MARK: - Reducer init(limit:)
    
    func test_initWithLimit_reduce_withTransformLimitingLength_shouldNotAppendExtraText_onLengthEqualLimit() {
        
        let reducer = makeReducer(limit: 5)
        
        assertReduce(
            state: .focus(text: "12345", cursorPosition: 5),
            with: .shouldChangeTextIn(.init(location: 5, length: 0), "ABC"),
            reducer: reducer,
            returns: .focus(text: "12345", cursorPosition: 5)
        )
    }
    
    func test_initWithLimit_reduce_withTransformLimitingLength_shouldAppendPartOfExtraText_onLengthLessThanLimit() {
        
        let reducer = makeReducer(limit: 6)
        
        assertReduce(
            state: .focus(text: "12345", cursorPosition: 5),
            with: .shouldChangeTextIn(.init(location: 5, length: 0), "ABC"),
            reducer: reducer,
            returns: .focus(text: "12345A", cursorPosition: 6)
        )
    }
    
    // MARK: - Helpers
    
    typealias ViewModel = TextFieldRegularView.ViewModel
    
    private func makeReducer(limit: Int) -> ViewModel.Reducer {
        
        .init(placeholderText: "Placeholder") { String($0.prefix(limit)) }
    }
    
    private func assertReduce(
        state: ViewModel.State,
        with action: ViewModel.Action,
        reducer: ViewModel.Reducer = .init(placeholderText: "Placeholder"),
        returns expected: ViewModel.State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let received = reducer.reduce(state: state, action: action)
        
        XCTAssertEqual(received, expected, "\n\n▽ Expected\n\(expected),\n\n▽ Received\n\(received).", file: file, line: line)
    }
}
