//
//  PhoneKitReducerTextFieldViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

@testable import Vortex
@testable import TextFieldComponent
@testable import TextFieldDomain
@testable import TextFieldUI
import XCTest

final class PhoneKitReducerTextFieldViewModelTests: XCTestCase {
    
    func test_init_shouldSetStateToPlaceholder_onNil() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_init_shouldSetStateToPlaceholder_onEmpty() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: "")
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_init_shouldSetStateToNoFocus_onNonEmpty_digits() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: "123")
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .noFocus("123")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_init_shouldSetStateToNoFocus_onNonEmpty_mix() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: "+1a23")
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .noFocus("+1a23")
        ])
        XCTAssertNotNil(sut)
        XCTAssertNotNil(scheduler)
    }
    
    func test_editing_shouldChangeStateFocus() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil)
        
        startEditing(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("", cursorAt: 0)),
        ])
    }
    
    func test_insertingMatch_shouldChangeState_withSubstitution_typeAbroad() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil, countryCodeReplaces: .test)
        
        startEditing(sut, on: scheduler)
        insertAtCursor("3", sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",     cursorAt: 0)),
            .editing(.init("+3", cursorAt: 2)),
        ])
    }
    
    func test_insertingMatch_shouldChangeState_withSubstitution_typeOther() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil, countryCodeReplaces: .test)
        
        startEditing(sut, on: scheduler)
        insertAtCursor("3", sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",     cursorAt: 0)),
            .editing(.init("+3", cursorAt: 2)),
        ])
    }
    
    func test_deleteLast_shouldChangeState_testAbroad() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil, countryCodeReplaces: .test)
        
        startEditing(sut, on: scheduler)
        insertAtCursor("3", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",     cursorAt: 0)),
            .editing(.init("+3", cursorAt: 2)),
            .editing(.init("",     cursorAt: 0)),
        ])
    }
    
    func test_deleteLast_shouldChangeState_testOther() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil, countryCodeReplaces: .test)
        
        startEditing(sut, on: scheduler)
        insertAtCursor("3", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",   cursorAt: 0)),
            .editing(.init("+3", cursorAt: 2)),
            .editing(.init("",   cursorAt: 0)),
        ])
    }
    
    func test_actionSeries_shouldChangeState_typeAbroad() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil, countryCodeReplaces: .test)
        
        startEditing(sut, on: scheduler)
        insertAtCursor("3", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        finishEditing(sut, on: scheduler)
        startEditing(sut, on: scheduler)
        insertAtCursor("99", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",       cursorAt: 0)),
            .editing(.init("+3",   cursorAt: 2)),
            .editing(.init("",    cursorAt: 0)),
            .placeholder("Enter phone number"),
            .editing(.init("",    cursorAt: 0)),
            .editing(.init("+9 9", cursorAt: 4)),
            .editing(.init("+9",   cursorAt: 2)),
            .editing(.init("",    cursorAt: 0)),
        ])
    }
    
    func test_actionSeries_shouldChangeState_typeOther() {
        
        let (sut, spy, scheduler) = makeSUT(initialValue: nil, countryCodeReplaces: .test)
        
        startEditing(sut, on: scheduler)
        insertAtCursor("3", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        finishEditing(sut, on: scheduler)
        startEditing(sut, on: scheduler)
        insertAtCursor("99", sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        deleteLast(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter phone number"),
            .editing(.init("",       cursorAt: 0)),
            .editing(.init("+3",   cursorAt: 2)),
            .editing(.init("",    cursorAt: 0)),
            .placeholder("Enter phone number"),
            .editing(.init("",    cursorAt: 0)),
            .editing(.init("+9 9", cursorAt: 4)),
            .editing(.init("+9",   cursorAt: 2)),
            .editing(.init("",       cursorAt: 0)),
        ])
    }

    
    // MARK: - Config
    
    func test_shouldSetToolbarWithBothButtons() {
        
        let (sut, _, scheduler) = makeSUT(initialValue: nil)
        
        scheduler.advance()
        
        XCTAssertNotNil(sut.toolbar?.closeButton)
        XCTAssertNotNil(sut.toolbar?.doneButton)
    }
    
    func test_shouldSetKeyboardTypeToNumberPad() {
        
        let (sut, _, scheduler) = makeSUT(initialValue: nil)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.keyboardType, .number)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialValue: String?,
        countryCodeReplaces: [CountryCodeReplace] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RegularFieldViewModel,
        spy: ValueSpy<TextFieldState>,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let sut = TextFieldFactory.makePhoneKitTextField(
            initialPhoneNumber: initialValue,
            placeholderText: "Enter phone number",
            filterSymbols: [],
            countryCodeReplaces: countryCodeReplaces,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    func startEditing(
        _ sut: RegularFieldViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.startEditing()
        scheduler.advance()
    }
    
    func finishEditing(
        _ sut: RegularFieldViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.finishEditing()
        scheduler.advance()
    }
    
    func insertAtCursor(
        _ text: String,
        _ sut: RegularFieldViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.insertAtCursor(text)
        scheduler.advance()
    }
    
    func deleteLast(
        _ sut: RegularFieldViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.deleteLast()
        scheduler.advance()
    }
}

extension TextFieldState {
    
    static func editing(_ view: TextState.View) -> Self {
        
        .editing(.init(view.text, cursorPosition: view.cursor))
    }
}
