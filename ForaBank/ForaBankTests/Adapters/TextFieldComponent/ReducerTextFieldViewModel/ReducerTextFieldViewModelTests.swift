//
//  ReducerTextFieldViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

@testable import ForaBank
@testable import TextFieldComponent
import SwiftUI
import XCTest

final class ReducerTextFieldViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialValues() {
        
        let sut = makeSUT(text: "text", placeholder: "Holder")
        
        XCTAssertNoDiff(sut.state, .noFocus("text"))
                        
        XCTAssertNoDiff(sut.text, "text")
        XCTAssertNoDiff(sut.state.isEditing, false)
    }
    
    func test_state_shouldPublishValue_onStateChange() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            text: "ABC",
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
    
    // MARK: - hasValue
    
    func test_hasValue_shouldReturnFalseOnNilText() {
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.text)
        XCTAssertFalse(sut.hasValue)
    }
    
    func test_hasValue_shouldReturnTrueOnNonNilText_text() {
        
        let sut = makeSUT(text: "ABC")
        
        XCTAssertNoDiff(sut.state, .noFocus("ABC"))
        XCTAssertNotNil(sut.text)
        XCTAssertTrue(sut.hasValue)
    }
    
    func test_hasValue_shouldReturnTrueOnNonNilText_focus() {
        
        let sut = makeSUT(text: "ABC")
        sut.startEditing()
        
        XCTAssertNoDiff(sut.state, .noFocus("ABC"))
        XCTAssertNotNil(sut.text)
        XCTAssertTrue(sut.hasValue)
    }
    
    // MARK: - Support Existing API
    
    func test_text_shouldPublishValue_onStateChange() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            text: "ABC",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.textPublisher(scheduler: scheduler.eraseToAnyScheduler()))
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, ["ABC"])
        
        sut.startEditing()

        scheduler.advance()
        XCTAssertNoDiff(spy.values, ["ABC", "ABC"])
        
        sut.setText(to: "123456")
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, ["ABC", "ABC", "123456"])
        
        sut.finishEditing()

        scheduler.advance()
        XCTAssertNoDiff(spy.values, ["ABC", "ABC", "123456", "123456"])
    }
    
    func test_isEditing_shouldPublishValue_onStateChange() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            text: "ABC",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.isEditing(scheduler: scheduler.eraseToAnyScheduler()))
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [false])
        
        sut.startEditing()
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [false, true])
        
        sut.setText(to: "123456")
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [false, true, true])
        
        sut.finishEditing()
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [false, true, true, false])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        text: String? = nil,
        placeholder: String = "Placeholder",
        isEditing: Bool = false,
        limit: Int? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> RegularFieldViewModel {
        
        let sut = TextFieldFactory.makeTextField(
            text: text,
            placeholderText: placeholder,
            keyboardType: .default,
            limit: limit,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension RegularTextFieldView.TextFieldConfig {
    
    static let test: Self = .makeDefault()
}
