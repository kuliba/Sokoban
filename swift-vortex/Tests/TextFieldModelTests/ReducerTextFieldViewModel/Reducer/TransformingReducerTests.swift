//
//  TransformingReducerTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class TransformingReducerTests: XCTestCase {
    
    let reducer = TransformingReducer(placeholderText: "A placeholder text")
    
    // MARK: - startEditing
    
    func test_reducer_shouldSetStateToEditingEmpty_fromPlaceholder_onStartEditing() throws {
        
        let state = TextFieldState("Any text")
        XCTAssertNoDiff(state, .placeholder("Any text"))
        
        assert(expect: .editing(.empty)) {
            try reducer.reduce(state, with: .startEditing)
        }
    }
    
    func test_reducer_shouldSetStateToEditingWithText_fromText_onStartEditing() throws {
        
        let text = "Any text"
        let state = TextFieldState.noFocus(text)
        
        assert(expect: .editing(.init(text))) {
            try reducer.reduce(state, with: .startEditing)
        }
    }
    
    // MARK: - finishEditing
    
    func test_reducer_shouldSetStateToPlaceholder_fromEditing_onFinishEditing_onEmptyText() throws {
        
        let state = TextFieldState.editing(.empty)
        
        assert(expect: .placeholder("A placeholder text")) {
            try reducer.reduce(state, with: .finishEditing)
        }
    }
    
    func test_reducer_shouldSetStateToText_fromEditing_onFinishEditing_onNonEmptyText() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        
        assert(expect: .noFocus("123456789")) {
            try reducer.reduce(state, with: .finishEditing)
        }
    }
    
    // MARK: - type (editing text)
    
    func test_reducer_shouldChangeTextState_inEditing_onDelete() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        
        assert(expect: .editing(.init("12356789", cursorAt: 3))) {
            try reducer.deleteAfterCursor(count: 1, in: state)
        }
    }
    
    func test_reducer_shouldChangeTextState_inEditing_onDelete2() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        
        assert(expect: .editing(.init("1236789", cursorAt: 3))) {
            try reducer.deleteAfterCursor(count: 2, in: state)
        }
    }
    
    func test_reducer_shouldChangeTextState_inEditing_onInsert_onNonEmpty() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        
        assert(expect: .editing(.init("123ABC456789", cursorAt: 6))) {
            try reducer.insertAtCursor("ABC", in: state)
        }
    }
    
    func test_reducer_shouldChangeTextState_inEditing_onInsert_onNonEmpty2() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        
        assert(expect: .editing(.init("123ABCDE456789", cursorAt: 8))) {
            try reducer.insertAtCursor("ABCDE", in: state)
        }
    }
    
    func test_reducer_shouldChangeTextState_inEditing_onReplace_onNonEmpty3() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        
        assert(expect: .editing(.init("123ABCDE789", cursorAt: 8))) {
            try reducer.replaceAfterCursor(3, with: "ABCDE", in: state)
        }
    }
    
    func test_reducer_shouldTransformTextState_inEditing() throws {
        
        let textState = TextState("123456789", cursorPosition: 3)
        let state = TextFieldState.editing(textState)
        let transformer = Transform(build: {
            Transform { textState in
                    .init(
                        textState.text.lowercased(),
                        cursorPosition: textState.cursorPosition
                    )
            }
            LimitingTransformer(6)
        })
        let reducer = TransformingReducer.init(
            placeholderText: "A placeholder text",
            transformer: transformer
        )
        
        assert(expect: .editing(.init("123abc", cursorAt: 6))) {
            try reducer.replaceAfterCursor(3, with: "ABCDE", in: state)
        }
    }
    
    func test_reducer_shouldSubstituteTextInState_inEditing() throws {
        
        let state = TextFieldState.editing(.empty)
        let transformer = Transformers.CountryCodeSubstitute(.test)
        let reducer = TransformingReducer.init(
            placeholderText: "A placeholder text",
            transformer: transformer
        )
        
        assert(expect: .editing(.init("3", cursorAt: 1))) {
            try reducer.insertAtCursor("3", in: state)
        }
    }
    
    // MARK: - setTextTo
    
    func test_reduce_shouldChangeStateFromTextToPlaceholder_onSetTextTo_nilText() throws {
        
        assertReduce(
            reducer,
            state: .noFocus("123456"),
            with: .setTextTo(nil),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_shouldChangeStateFromEditingToPlaceholder_onSetTextTo_nilText() throws {
        
        assertReduce(
            reducer,
            state: .editing(.init("123456", cursorAt: 6)),
            with: .setTextTo(nil),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_shouldNotChangePlaceholderState_onSetTextTo_nilText() throws {
        
        assertReduce(
            reducer,
            state: .placeholder("A placeholder text"),
            with: .setTextTo(nil),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_shouldChangeStateFromTextToPlaceholder_onSetTextTo_onEmpty() throws {
        
        assertReduce(
            reducer,
            state: .noFocus("123456"),
            with: .setTextTo(""),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_shouldSetTextStateToEmptyInEditing_onSetTextTo_onEmpty() throws {
        
        assertReduce(
            reducer,
            state: .editing(.init("123456", cursorAt: 6)),
            with: .setTextTo(""),
            returns: .editing(.empty)
        )
    }
    
    func test_reduce_shouldNotChangePlaceholderState_onSetTextTo_onEmpty() throws {
        
        assertReduce(
            reducer,
            state: .placeholder("A placeholder text"),
            with: .setTextTo(""),
            returns: .noFocus("")
        )
    }
    
    func test_reduce_setText_shouldNotChangeEditingState_onSameEmptyText() throws {
        
        let emptyText = ""
        let textState = TextState(emptyText, cursorPosition: 0)
        
        assertReduce(
            reducer,
            state: .editing(textState),
            with: .setTextTo(emptyText),
            returns: .editing(textState)
        )
    }
    
    func test_reduce_setText_shouldNotChangeEditingState_onSameText_cursorAtStart() throws {
        
        let nonEmptyText = "non empty"
        let textState = TextState(nonEmptyText, cursorPosition: 0)
        
        assertReduce(
            reducer,
            state: .editing(textState),
            with: .setTextTo(nonEmptyText),
            returns: .editing(textState)
        )
    }
    
    func test_reduce_setText_shouldNotChangeEditingState_onSameText_cursorInside() throws {
        
        let nonEmptyText = "non empty"
        let textState = TextState(nonEmptyText, cursorPosition: 4)
        
        assertReduce(
            reducer,
            state: .editing(textState),
            with: .setTextTo(nonEmptyText),
            returns: .editing(textState)
        )
    }
    
    func test_reduce_setText_shouldNotChangeEditingState_onSameText_cursorAtEnd() throws {
        
        let nonEmptyText = "non empty"
        let textState = TextState(
            nonEmptyText,
            cursorPosition: nonEmptyText.count
        )
        
        assertReduce(
            reducer,
            state: .editing(textState),
            with: .setTextTo(nonEmptyText),
            returns: .editing(textState)
        )
    }
    
    func test_reduce_withLimitingTransform_shouldChangeFromTextToPlaceholder_onEmpty() {
        
        let reducer = makeLimitReducer(limit: 6)
        
        assertReduce(
            reducer,
            state: .noFocus("12345"),
            with: .setTextTo(""),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_withLimitingTransform_shouldSetTextStateToEmptyInEditing_onSetTextTo_onEmpty() throws {
        
        let reducer = makeLimitReducer(limit: 6)
        
        assertReduce(
            reducer,
            state: .editing(.init("123456", cursorAt: 6)),
            with: .setTextTo(""),
            returns: .editing(.empty)
        )
    }
    
    func test_reduce_withLimitingTransform_shouldNotChangePlaceholderState_onSetTextTo_onEmpty() throws {
        
        let reducer = makeLimitReducer(limit: 6)
        
        assertReduce(
            reducer,
            state: .placeholder("A placeholder text"),
            with: .setTextTo(""),
            returns: .noFocus("")
        )
    }
    
    func test_reduce_withLimitingTransform_shouldChangeTextInTextState_onSetTextTo_nonNilText() {
        
        let reducer = makeLimitReducer(limit: 6)
        
        assertReduce(
            reducer,
            state: .noFocus("123456"),
            with: .setTextTo("ABC"),
            returns: .noFocus("ABC")
        )
    }
    
    func test_reduce_shouldChangeTextInEditing_onSetTextTo_nonNilText() {
        
        assertReduce(
            reducer,
            state: .editing(.init("123456", cursorAt: 6)),
            with: .setTextTo("ABC"),
            returns: .editing(.init("ABC", cursorAt: 3))
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeStateFromEditingToPlaceholder_onSetTextTo_nilText() {
        
        let reducer = makeLimitReducer(limit: 3)
        
        assertReduce(
            reducer,
            state: .editing(.init(("123456"))),
            with: .setTextTo(nil),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_shouldSetTextStateToEmpty_onSetTextTo_emptyText() {
        
        assertReduce(
            reducer,
            state: .editing(.init("123456")),
            with: .setTextTo(""),
            returns: .editing(.empty)
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeFromEditingToPlaceholder_onSetTextTo_nilText() {
        
        let reducer = makeLimitReducer(limit: 3)
        
        assertReduce(
            reducer,
            state: .editing(.init("123456", cursorAt: 6)),
            with: .setTextTo(nil),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeTextInTextState_onSetTextTo_nonNilText() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .noFocus("12"),
            with: .setTextTo("ABC"),
            returns: .noFocus("AB")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeTextInFocus_onSetTextTo_nonNilText() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .editing(.init("12", cursorAt: 1)),
            with: .setTextTo("ABC"),
            returns: .editing(.init("AB", cursorAt: 2))
        )
    }
    
    // MARK: - Edge Cases
    
    func test_reduce_withLimitingTransformer_shouldNotChangeStateInPlaceholder_onChangeTextInRange() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .placeholder("Placeholder"),
            with: .changeText("ABC", in: .init(location: 1, length: 1)),
            returns: .placeholder("Placeholder")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldNotChangeStateInPlaceholder_onSetTextToNil() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .placeholder("A placeholder text"),
            with: .setTextTo(nil),
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeStateToTextFromPlaceholder_onSetTextTo() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .placeholder("A placeholder text"),
            with: .setTextTo("ABC"),
            returns: .noFocus("AB")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldNotChangeStateInPlaceholder_onFinishEditing() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .placeholder("A placeholder text"),
            with: .finishEditing,
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldNotChangeState_onStartEditing() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .editing(.init("12", cursorAt: 1)),
            with: .startEditing,
            returns: .editing(.init("12", cursorAt: 1))
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeTextInFocusState_onChangeTextInRange() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .editing(.init("12", cursorAt: 1)),
            with: .changeText("ABC", in: .init(location: 1, length: 1)),
            returns: .editing(.init("1A", cursorAt: 2))
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldNotChangeTextStateWithState_onChangeTextInRange() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .noFocus("1234567"),
            with: .changeText("ABC", in: .init(location: 1, length: 1)),
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldNotChangeTextStateWithEmptyTextState_onChangeTextInRange() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .noFocus(""),
            with: .changeText("ABC", in: .init(location: 1, length: 1)),
            returns: .noFocus("")
        )
    }
    
    func test_reduce_withLimitingTransformer_shouldChangeTextInFocus_onChangeTextInRange() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .editing(.init("12", cursorAt: 1)),
            with: .changeText("ABC", in: .init(location: 1, length: 1)),
            returns: .editing(.init("1A", cursorAt: 2))
        )
    }
    
    func test_reduce_shouldChangeTextInText_onFinishEditing() {
        
        assertReduce(
            reducer,
            state: .noFocus("1234567"),
            with: .finishEditing,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeTextInNoFocus_onFinishEditing() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .noFocus("1234567"),
            with: .finishEditing,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_shouldChangeStateToNoFocus_onFinishEditing() {
        
        assertReduce(
            reducer,
            state: .editing(.init("1234567", cursorAt: 5)),
            with: .finishEditing,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeStateToNoFocus_onFinishEditing() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .editing(.init("1234567", cursorAt: 5)),
            with: .finishEditing,
            returns: .noFocus("1234567")
        )
    }
    
    func test_reduce_shouldChangeStateFromEditingToPlaceholder_onEmpty_onFinishEditing() {
        
        assertReduce(
            reducer,
            state: .editing(.init("", cursorAt: 0)),
            with: .finishEditing,
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_withTransformLimitingLength_shouldChangeStateToPlaceholder_onEmpty_onFinishEditing() {
        
        let reducer = makeLimitReducer(limit: 2)
        
        assertReduce(
            reducer,
            state: .editing(.init("", cursorAt: 0)),
            with: .finishEditing,
            returns: .placeholder("A placeholder text")
        )
    }
    
    func test_reduce_withLimitingTransform_shouldNotAppendExtraText_onLengthEqualLimit() {
        
        let reducer = makeLimitReducer(limit: 5)
        
        assertReduce(
            reducer,
            state: .editing(.init("12345", cursorAt: 5)),
            with: .changeText("ABC", in: .init(location: 5, length: 0)),
            returns: .editing(.init("12345", cursorAt: 5))
        )
    }
    
    func test_reduce_withLimitingTransform_shouldAppendPartOfExtraText_onLengthLessThanLimit() {
        
        let reducer = makeLimitReducer(limit: 6)
        
        assertReduce(
            reducer,
            state: .editing(.init("12345", cursorAt: 5)),
            with: .changeText("ABC", in: .init(location: 5, length: 0)),
            returns: .editing(.init("12345A", cursorAt: 6))
        )
    }
    
    // MARK: - identity reducer
    
    func test_identityReducer_shouldSetCursorAtInsertionTextEnd () {
        
        assertReduce(
            makeIdentityReducer(),
            state: .editing(.init("12345")),
            with: .insert("abc", at: 2),
            returns: .editing(.init("12abc345", cursorAt: 5))
        )
    }
    
    // MARK: - Helpers
    
    private func makeLimitReducer(limit: Int) -> Reducer {
        
        TransformingReducer(
            placeholderText: "A placeholder text",
            transformer: Transformers.Limiting(limit)
        )
    }
    
    private func makeIdentityReducer() -> Reducer {
        
        TransformingReducer(
            placeholderText: "A placeholder text"
        )
    }
    
    func assert(
        expect expectedState: TextFieldState,
        _ action: () throws -> TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(try action(), expectedState, file: file, line: line)
    }
    
    func assertReduce(
        _ reducer: Reducer,
        state: TextFieldState,
        with action: TextFieldAction,
        returns expectedState: TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            try reducer.reduce(state, with: action),
            expectedState,
            file: file, line: line
        )
    }
}

private extension TextFieldAction {
    
    static func insert(
        _ text: String,
        at cursorPosition: Int
    ) -> Self {
        
        .changeText(text, in: .init(location: cursorPosition, length: 0))
    }
}
