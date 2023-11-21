//
//  TextFieldFactory+makeTextFieldTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class TextFieldFactory_makeTextFieldTests: XCTestCase {
    
    func test_init_shouldSetToDefaultPlaceholderOnEmptyText() {
        
        let (_,_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("a placeholder")
        ])
    }
    
    func test_init_shouldSetToNoFocusWithTextOnNonEmptyText() {
        
        let (_,_, spy) = makeSUT(initialText: "some text")
        
        XCTAssertNoDiff(spy.values, [
            .noFocus("some text")
        ])
    }
    
    func test_insertAtNotEnd_shouldNotMoveCursorToEnd() {
        
        let (sut, scheduler, spy) = makeSUT()
        
        sut.startEditing()
        XCTAssertNoDiff(spy.values, [
            .placeholder("a placeholder"),
        ])
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .placeholder("a placeholder"),
            .editing(.init("", cursorAt: 0)),
        ])
        
        sut.type("abcd", in: .zero)
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .placeholder("a placeholder"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("abcd", cursorAt: 6)),
        ])
        
        sut.insert("-", atCursor: 2)
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .placeholder("a placeholder"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("abcd", cursorAt: 6)),
            .editing(.init("ab-cd", cursorAt: 3)),
        ])
        
        scheduler.advance(by: 999)
        XCTAssertNoDiff(spy.values, [
            .placeholder("a placeholder"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("abcd", cursorAt: 6)),
            .editing(.init("ab-cd", cursorAt: 3)),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RegularFieldViewModel
    private typealias Spy = ValueSpy<TextFieldState>
    
    private func makeSUT(
        initialText: String = "",
        limit: Int? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: Spy
    ) {
        let scheduler = DispatchQueue.test
        let sut = TextFieldFactory.makeTextField(
            text: initialText,
            placeholderText: "a placeholder",
            keyboardType: .default,
            limit: limit,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, scheduler, spy)
    }
}
