//
//  ReducerTextFieldViewModel+DSLTests.swift
//  
//
//  Created by Igor Malyarov on 01.06.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class ReducerTextFieldViewModel_DSLTests: XCTestCase {
    
    // MARK: - append
    
    func test_append_shouldThrowOnPlaceholderState() throws {
        
        let state: TextFieldState = .placeholder("A placeholder")
        let (sut, scheduler, _) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.state, state)
        
        XCTAssertThrowsError(
            try sut.append("")
        ) {
            XCTAssertNoDiff(
                ($0 as NSError).domain,
                "Expected `editing` state, got placeholder(\"A placeholder\")"
            )
        }
        
        XCTAssertEqual(sut.state, state)
    }
    
    func test_append_shouldThrowOnNoFocusState() throws {
        
        let state: TextFieldState = .noFocus("any text")
        let (sut, scheduler, _) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.state, state)
        
        XCTAssertThrowsError(
            try sut.append("")
        ) {
            XCTAssertNoDiff(
                ($0 as NSError).domain,
                "Expected `editing` state, got noFocus(\"any text\")"
            )
        }
        
        XCTAssertEqual(sut.state, state)
    }
    
    func test_append_shouldAppendToEmptyOnEditingState() throws {
        
        let state: TextFieldState = .editing(.empty)
        let (sut, scheduler, spy) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [state])
        
        try sut.append("Abc")
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            state,
            .editing(.init("Abc", cursorPosition: 3))
        ])
    }
    
    func test_append_shouldAppendToNonEmptyOnEditingState() throws {
        
        let state: TextFieldState = .editing(.init("1234", cursorAt: 4))
        let (sut, scheduler, spy) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [state])
        
        try sut.append("Abc")
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            state,
            .editing(.init("1234Abc", cursorPosition: 7))
        ])
    }
    
    // MARK: - removeLast
    
    func test_removeLast_shouldThrowOnPlaceholderState() throws {
        
        let state: TextFieldState = .placeholder("A placeholder")
        let (sut, scheduler, _) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.state, state)
        
        XCTAssertThrowsError(
            try sut.removeLast()
        ) {
            XCTAssertNoDiff(
                ($0 as NSError).domain,
                "Expected `editing` state, got placeholder(\"A placeholder\")"
            )
        }
        
        XCTAssertEqual(sut.state, state)
    }
    
    func test_removeLast_shouldThrowOnNoFocusState() throws {
        
        let state: TextFieldState = .noFocus("any text")
        let (sut, scheduler, _) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.state, state)
        
        XCTAssertThrowsError(
            try sut.removeLast()
        ) {
            XCTAssertNoDiff(
                ($0 as NSError).domain,
                "Expected `editing` state, got noFocus(\"any text\")"
            )
        }
        
        XCTAssertEqual(sut.state, state)
    }
    
    func test_removeLast_shouldThrowOnEditingState_negativeK() throws {
        
        let state: TextFieldState = .editing(.init("Abc", cursorAt: 1))
        let (sut, scheduler, _) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.state, state)
        
        XCTAssertThrowsError(
            try sut.removeLast(-1)
        ) {
            XCTAssertNoDiff(
                ($0 as NSError).domain,
                "Cannot remove negative number of characters."
            )
        }
        
        XCTAssertEqual(sut.state, state)
    }
    
    func test_removeLast_one() throws {
        
        let state: TextFieldState = .editing(.init("Abc", cursorAt: 2))
        let (sut, scheduler, spy) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [state])
        
        try sut.removeLast()
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            state,
            .editing(.init("Ab", cursorPosition: 2))
        ])
    }
    
    func test_removeLast_all() throws {
        
        let state: TextFieldState = .editing(.init("Abc", cursorAt: 2))
        let (sut, scheduler, spy) = makeSUT(state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [state])
        
        try sut.removeLast(3)
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            state,
            .editing(.empty)
        ])
    }
    
    // MARK - Helpers
    
    private typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

    private func makeSUT(
        _ initialState: TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: ValueSpy<TextFieldState>
    ) {
        let reducer: TransformingReducer = .init(placeholderText: "A placeholder")
        let scheduler = DispatchQueue.test
        let sut: ViewModel = .init(
            initialState: initialState,
            reducer: reducer,
            keyboardType: .init(),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, scheduler, spy)
    }
    
    private struct ToolbarViewModel: Equatable {}

    private struct KeyboardType: Equatable {}
}
