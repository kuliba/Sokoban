//
//  ViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import CombineSchedulers
@testable import TextFieldRegularComponent
import SwiftUI
import XCTest

final class ViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialValues() {
        
        let sut = makeSUT(text: "text", placeholder: "Holder")
        
        XCTAssertEqual(sut.state, .noFocus("text"))
                
        XCTAssertNotNil(sut.toolbar)
        
        XCTAssertEqual(sut.text, "text")
        XCTAssertEqual(sut.isEditing, false)
    }
    
    func test_state_shouldPublishValue_onStateChange() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            text: "ABC",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [
            .noFocus("ABC"),
        ])
        
        sut.textViewDidBeginEditing()
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [
            .noFocus("ABC"),
            .focus(text: "ABC", cursorPosition: 3),
        ])
        
        sut.setText(to: "123456")
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [
            .noFocus("ABC"),
            .focus(text: "ABC", cursorPosition: 3),
            .focus(text: "123456", cursorPosition: 6),
        ])
        
        sut.textViewDidEndEditing()
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [
            .noFocus("ABC"),
            .focus(text: "ABC", cursorPosition: 3),
            .focus(text: "123456", cursorPosition: 6),
            .noFocus("123456")
        ])
    }
    
    // MARK: - hasValue
    
    func test_hasValue_shouldReturnFalseOnNilText() {
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.text)
        XCTAssertFalse(sut.hasValue)
    }
    
    func test_hasValue_shouldReturnTrueOnNonNilText_noFocus() {
        
        let sut = makeSUT(text: "ABC")
        
        XCTAssertEqual(sut.state, .noFocus("ABC"))
        XCTAssertNotNil(sut.text)
        XCTAssertTrue(sut.hasValue)
    }
    
    func test_hasValue_shouldReturnTrueOnNonNilText_focus() {
        
        let sut = makeSUT(text: "ABC")
        sut.textViewDidBeginEditing()
        
        XCTAssertEqual(sut.state, .noFocus("ABC"))
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
        let spy = ValueSpy(sut.$text.dropFirst())
        
        scheduler.advance()
        XCTAssertEqual(spy.values, ["ABC"])
        
        sut.textViewDidBeginEditing()

        scheduler.advance()
        XCTAssertEqual(spy.values, ["ABC"])
        
        sut.setText(to: "123456")
        
        scheduler.advance()
        XCTAssertEqual(spy.values, ["ABC", "123456"])
        
        sut.textViewDidEndEditing()

        scheduler.advance()
        XCTAssertEqual(spy.values, ["ABC", "123456"])
    }
    
    func test_isEditing_shouldPublishValue_onStateChange() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            text: "ABC",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$isEditing.dropFirst())
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [false])
        
        sut.textViewDidBeginEditing()
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [false, true])
        
        sut.setText(to: "123456")
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [false, true])
        
        sut.textViewDidEndEditing()
        
        scheduler.advance()
        XCTAssertEqual(spy.values, [false, true, false])
    }
    
    // MARK: - Helpers
    
    typealias ViewModel = TextFieldRegularView.ViewModel
    
    private func makeSUT(
        text: String? = nil,
        placeholder: String = "Placeholder",
        isEditing: Bool = false,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> ViewModel {
        
        let sut = ViewModel(
            text: text,
            placeholder: placeholder,
            keyboardType: .default,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

private extension TextFieldRegularView.TextFieldConfig {
    
    static let test: Self = .init(font: .systemFont(ofSize: 19), textColor: .blue, tintColor: .orange, backgroundColor: .clear)
}
