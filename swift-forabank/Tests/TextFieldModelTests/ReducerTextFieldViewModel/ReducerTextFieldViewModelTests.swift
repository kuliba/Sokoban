//
//  ReducerTextFieldViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import SwiftUI
import XCTest

final class ReducerTextFieldViewModelTests: XCTestCase {
    
    func test_init_shouldSetStateInitialValue_placeholder() {
        
        let sut = makeSUT(.placeholder("A placeholder"))
        
        XCTAssertNoDiff(sut.state, .placeholder("A placeholder"))
    }
    
    func test_init_shouldSetStateInitialValue_text() {
        
        let sut = makeSUT(.noFocus("text"))
        
        XCTAssertNoDiff(sut.state, .noFocus("text"))
    }
    
    func test_init_shouldSetStateInitialValue_editing() {
        
        let sut = makeSUT(.editing(.init("text")))
        
        XCTAssertNoDiff(sut.state, .editing(.init("text")))
    }
    
    func test_init_shouldSetStateInitialValue_editingWithCursor() {
        
        let sut = makeSUT(.editing(.init("text", cursorPosition: 3)))
        
        XCTAssertNoDiff(sut.state, .editing(.init("text", cursorAt: 3)))
    }
    
    func test_init_shouldSetToolbar() {
        
        let sut = makeSUT(.noFocus(""))
        
        XCTAssertNoDiff(sut.toolbar, .init())
    }
        
    func test_state_shouldPublishValue_onStateChange() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            .noFocus("ABC"),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .noFocus("ABC"),
        ])
        
        sut.startEditing()
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .noFocus("ABC"),
            .editing(.init("ABC", cursorAt: 3)),
        ])
        
        sut.setText(to: "123456")
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .noFocus("ABC"),
            .editing(.init("ABC",    cursorAt: 3)),
            .editing(.init("123456", cursorAt: 6)),
        ])
        
        sut.finishEditing()
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .noFocus("ABC"),
            .editing(.init("ABC",    cursorAt: 3)),
            .editing(.init("123456", cursorAt: 6)),
            .noFocus("123456")
        ])
    }
    
    // MARK: - with transformer
    
    func test_init_shouldSetStateToPlaceholder_onNil() {
        
        let (sut, spy, scheduler) = makeSUT(nil)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_init_shouldSetStateToPlaceholder_onEmpty() {
        
        let (sut, spy, scheduler) = makeSUT("")
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .noFocus("")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_init_shouldSetStateToNoFocus_onNonEmpty_digits() {
        
        let (sut, spy, scheduler) = makeSUT("123")
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .noFocus("123")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_init_shouldSetStateToNoFocus_onNonEmpty_mix() {
        
        let (sut, spy, scheduler) = makeSUT("+1a23")
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .noFocus("+1a23")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_editing_shouldChangeStateFocus() {
        
        let (sut, spy, scheduler) = makeSUT(nil)
        
        beginEditing(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("", cursorAt: 0)),
        ])
    }
    
    func test_typing_shouldChangeState_withReplacement() {
        
        let (sut, spy, scheduler) = makeSUT(nil, substitutions: .test)
        
        beginEditing(sut, on: scheduler)
        replaceWith("3", sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",    cursorAt: 0)),
            .editing(.init("3", cursorAt: 1)),
        ])
    }
    
    func test_deleteLast_shouldChangeState() {
        
        let (sut, spy, scheduler) = makeSUT(nil, substitutions: .test)
        
        beginEditing(sut, on: scheduler)
        replaceWith("3", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",    cursorAt: 0)),
            .editing(.init("3", cursorAt: 1)),
            .editing(.init("",  cursorAt: 0))
        ])
    }
    
    // MARK: - Helpers
    
    private typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>
    
    private func makeSUT(
        _ state: TextFieldState,
        placeholderText: String = "Placeholder",
        keyboardType: KeyboardType = .init(),
        toolbar: ToolbarViewModel = .init(),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ViewModel {
        
        let sut = ViewModel(
            initialState: state,
            reducer: TransformingReducer(placeholderText: placeholderText),
            keyboardType: keyboardType,
            toolbar: toolbar,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(
        _ text: String?,
        substitutions: [CountryCodeSubstitution] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        spy: ValueSpy<TextFieldState>,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let placeholderText = "Enter phone number"
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: Transform(build: {
                CountryCodeSubstitutionTransformer(substitutions)
            })
        )
        let sut = ViewModel(
            initialState: {
                if let text {
                    return .noFocus(text)
                } else {
                    return .placeholder(placeholderText)
                }
            }(),
            reducer: reducer,
            keyboardType: .init(),
            toolbar: .init(),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func beginEditing(
        _ sut: ViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.startEditing()
        scheduler.advance()
    }
    
    private func replaceWith(
        _ text: String,
        _ sut: ViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.setText(to: text)
        scheduler.advance()
    }
    
    private func deleteLast(
        _ sut: ViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.deleteLast()
        scheduler.advance()
    }
    
    private struct ToolbarViewModel: Equatable {}

    private struct KeyboardType: Equatable {}
}
