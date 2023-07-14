//
//  ReducerTextFieldViewModelWithTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 16.05.2023.
//

import CombineSchedulers
@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class ReducerTextFieldViewModelWithTransformerTests: XCTestCase {
    
    func test_init_shouldSetInitialValues() {
        
        let scheduler = DispatchQueue.test
        let (sut, spy) = makeSUT(scheduler: scheduler.eraseToAnyScheduler())
        
        XCTAssertNoDiff(spy.values, [.placeholder("A placeholder text")])
        XCTAssertNoDiff(sut.keyboardType, .init())
        XCTAssertNoDiff(sut.toolbar, .init())
    }
    
    func test_shouldChangeState_onBeginAndEndEditing() {
        
        let scheduler = DispatchQueue.test
        let (sut, spy) = makeSUT(scheduler: scheduler.eraseToAnyScheduler())
        
        sut.startEditing(on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("A placeholder text"),
            .editing(.init("", cursorAt: 0)),
        ])
        
        sut.finishEditing(on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("A placeholder text"),
            .editing(.init("", cursorAt: 0)),
            .placeholder("A placeholder text"),
        ])
    }
    
    func test_shouldChangeState_onTyping() {
        
        let scheduler = DispatchQueue.test
        let (sut, spy) = makeSUT(scheduler: scheduler.eraseToAnyScheduler())
        
        sut.startEditing(on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("A placeholder text"),
            .editing(.init("", cursorAt: 0)),
        ])
        
        sut.replaceWith("abcde", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("A placeholder text"),
            .editing(.init("",      cursorAt: 0)),
            .editing(.init("ABCDE", cursorAt: 5)),
        ])
        
        sut.finishEditing(on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("A placeholder text"),
            .editing(.init("",      cursorAt: 0)),
            .editing(.init("ABCDE", cursorAt: 5)),
            .noFocus("ABCDE"),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

    private func makeSUT(
        scheduler: AnySchedulerOf<DispatchQueue>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        spy: ValueSpy<TextFieldState>
    ) {
        
        let placeholderText = "A placeholder text"
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transform: {
                .init(
                    $0.text.uppercased(),
                    cursorPosition: $0.cursorPosition
                )
            }
        )
        let sut = ViewModel.init(
            initialState: .placeholder(placeholderText),
            reducer: reducer,
            keyboardType: .init(),
            toolbar: .init(),
            scheduler: scheduler
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private struct ToolbarViewModel: Equatable {}

    private struct KeyboardType: Equatable {}
}
