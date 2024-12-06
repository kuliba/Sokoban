//
//  TransformingReducerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.11.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class TransformingReducerTests: XCTestCase {
    
    // MARK: - non limiting reducer
    
    func test_identityReducer_shouldSetCursorAtInsertionTextEnd () {
        
        assertReduce(
            makeNonLimitingReducer(),
            state: .editing(.init("12345")),
            with: .insert("abc", at: 2),
            returns: .editing(.init("12abc345", cursorAt: 5))
        )
    }
    
    // MARK: - limiting reducer
    
    func test_limitingReducer_shouldSetCursorAtInsertionTextEnd () {
        
        assertReduce(
            makeLimitingReducer(),
            state: .editing(.init("12345")),
            with: .insert("abc", at: 2),
            returns: .editing(.init("12abc345", cursorAt: 5))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Reducer = TextFieldComponent.Reducer
    
    private func makeNonLimitingReducer() -> Reducer {
        
        TransformingReducer(
            placeholderText: "A placeholder text",
            limit: nil
        )
    }
    
    private func makeLimitingReducer(limit: Int = 10) -> Reducer {
        
        TransformingReducer(
            placeholderText: "A placeholder text",
            limit: limit
        )
    }
    
    private func assertReduce(
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
