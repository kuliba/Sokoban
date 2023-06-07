//
//  ItemSelectModelTests.swift
//  
//
//  Created by Igor Malyarov on 01.06.2023.
//

import Combine
import TextFieldDomain
import XCTest

private typealias Model = ItemSelectModel<TestItem>
private typealias State = Model.State
private typealias Action = Model.Action

final class ItemSelectModelTests: XCTestCase {
    
    // MARK: - select
    
    func test_select_shouldToggleStateToSelectedCollapsed_fromSelectedExpanded() {
        
        let state: State = .selected(.az, listState: .expanded)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .selected(.az, listState: .expanded),
            .selected(.am, listState: .collapsed),
        ])
    }
    
    func test_select_shouldToggleListState() {
        
        let state: State = .selected(.az, listState: .expanded)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .selected(.az, listState: .expanded),
            .selected(.am, listState: .collapsed),
            .selected(.am, listState: .expanded),
        ])
    }
    
    func test_select_shouldToggleStateToSelectedExpanded_fromSelectedCollapsed() {
        
        let state: State = .selected(.az, listState: .collapsed)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .selected(.az, listState: .collapsed),
            .selected(.am, listState: .expanded),
        ])
    }
    
    func test_select_shouldNotChangeFromCollapsedState() {
        
        let state: State = .collapsed
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
        ])
    }
    
    func test_select_shouldChangeToSelectedFromExpandedState() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .selected(.am, listState: .collapsed)
        ])
    }
    
    func test_select_shouldToggleListStateOnSelection() {
        
        let state: State = .selected(.az, listState: .expanded)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .selected(.az, listState: .expanded),
            .selected(.am, listState: .collapsed),
            .selected(.am, listState: .expanded),
        ])
    }
    
    // MARK: - select -> textField
    
    func test_select_shouldSendMessageToTextFieldFromSelectedExpanded() {
        
        let state: State = .selected(.az, listState: .expanded)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.select(.am)])
    }
    
    func test_select_shouldNotSendMessageToTextFieldFromSelectedCollapsed() {
        
        let state: State = .selected(.az, listState: .collapsed)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [])
    }
    
    func test_select_shouldNotSendMessageToTextFieldFromCollapsedState() {
        
        let state: State = .collapsed
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [])
    }
    
    func test_select_shouldSendMessageToTextFieldFromExpandedState() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.select(.am), on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.select(.am)])
    }
    
    // MARK: - toggleListVisibility
    
    func test_toggleListVisibility_shouldChangeExpandedStateToCollapsed() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .collapsed
        ])
    }
    
    func test_toggleListVisibility_shouldChangeCollapsedStateToExpanded() {
        
        let state: State = .collapsed
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .expanded(.allItems)
        ])
    }
    
    func test_toggleListVisibility_shouldChangeSelectedCollapsedStateToSelectedExpanded() {
        
        let state: State = .selected(.am, listState: .collapsed)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .selected(.am, listState: .collapsed),
            .selected(.am, listState: .expanded),
        ])
    }
    
    func test_toggleListVisibility_shouldChangeSelectedExpandedStateToSelectedCollapsed() {
        
        let state: State = .selected(.am, listState: .expanded)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .selected(.am, listState: .expanded),
            .selected(.am, listState: .collapsed),
        ])
    }
    
    // MARK: - toggleListVisibility -> textField
    
    func test_toggleListVisibility_shouldSendFinishEditingMessageToTextFieldFromExpandedState() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.finishEditing])
    }
    
    func test_toggleListVisibility_shouldSendFinishEditingToTextFieldFromExpandedState() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.finishEditing])
    }
    
    func test_toggleListVisibility_shouldSendStartEditingToTextFieldFromCollapsedState() {
        
        let state: State = .collapsed
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.startEditing])
    }
    
    func test_toggleListVisibility_shouldSendStartEditingMessageToTextFieldFromCollapsedState() {
        
        let state: State = .collapsed
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.startEditing])
    }
    
    func test_toggleListVisibility_shouldSenfStartEditingToTextFieldFromSelectedCollapsedState() {
        
        let state: State = .selected(.am, listState: .collapsed)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.startEditing])
    }
    
    func test_toggleListVisibility_shouldSendStartEditingMessageToTextFieldFromSelectedCollapsedState() {
        
        let state: State = .selected(.am, listState: .collapsed)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.startEditing])
    }
    
    func test_toggleListVisibility_shouldSendFinishEditingMessageToTextFieldFromSelectedExpandedState() {
        
        let state: State = .selected(.am, listState: .expanded)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.finishEditing])
    }
    
    func test_toggleListVisibility_shouldSenfFinishEditingToTextFieldFromSelectedExpandedState() {
        
        let state: State = .selected(.am, listState: .expanded)
        let (sut, scheduler, _, textField) = makeSUT(initialState: state)
        
        sut.send(.toggleListVisibility, on: scheduler)
        
        XCTAssertNoDiff(textField.messages, [.finishEditing])
    }
    
    // MARK: - filterList
    
    func test_filterList_shouldNotChangeStateOnCollapsed() {
        
        let state: State = .collapsed
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.filterList(nil), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
        ])
    }
    
    func test_filterList_shouldNotChangeStateOnSelectedCollapsed() {
        
        let state: State = .selected(.am, listState: .collapsed)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.filterList(nil), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            state
        ])
    }
    
    func test_filterList_shouldNotChangeStateOnSelectedExpanded() {
        
        let state: State = .selected(.am, listState: .expanded)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.filterList(nil), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            state
        ])
    }
    
    func test_filterList_shouldNotFilterItemsOnExpanded_nilText() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.filterList(nil), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .expanded(.allItems),
        ])
    }
    
    func test_filterList_shouldNotFilterItemsOnExpanded_emptyText() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.filterList(""), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .expanded(.allItems),
        ])
    }
    
    func test_filterList_shouldFilterItemsOnExpanded_nonEmptyText() {
        
        let state: State = .expanded(.allItems)
        let (sut, scheduler, spy, _) = makeSUT(initialState: state)
        
        sut.send(.filterList("А"), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .expanded([.am, .az]),
        ])
        
        sut.send(.filterList("Арм"), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .expanded([.am, .az]),
            .expanded([.am]),
        ])
        
        sut.send(.filterList(""), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .expanded(.allItems),
            .expanded([.am, .az]),
            .expanded([.am]),
            .expanded(.allItems),
        ])
    }
    
    // MARK: - textField state change observation
    
    func test_textField_changeFromPlaceholderToEditing_shouldSetStateToExpanded() {
        
        let (_, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .placeholder("A placeholder"))
        textField.setState(to: .editing(.empty))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .collapsed,
            .expanded(.allItems)
        ])
    }
    
    func test_textField_changeFromNoFocusToEditing_shouldSetStateToExpandedWithFilteredItems() {
        
        let (sut, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .noFocus("А"))
        textField.setState(to: .editing(.init("А", cursorPosition: 1)))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .collapsed,
            .expanded([.am, .az])
        ])
        XCTAssertEqual(sut.state, .expanded([.am, .az]))
    }
    
    func test_textField_changeFromNoFocusToEditing_shouldSetStateToExpandedWithEmptyItems_onNoFilterMatch() {
        
        let (_, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .noFocus("z"))
        textField.setState(to: .editing(.init("z", cursorPosition: 1)))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .collapsed,
            .expanded([])
        ])
    }
    
    func test_textField_changeFromNoFocusToEditing_shouldSetStateToSelectExpanded_onMatchedItem() {
        
        let (_, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .editing(.empty))
        textField.setState(to: .editing(.init("Армения", cursorPosition: 7)))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .expanded(.allItems),
            .selected(.am, listState: .expanded)
        ])
    }
    
    func test_textField_changeFromEditingToNoFocusWithoutMatch_shouldSetStateToCollapsed() {
        
        let (_, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .editing(.init("Арм", cursorPosition: 3)))
        textField.setState(to: .noFocus("Арм"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .expanded([.am]),
            .collapsed,
        ])
    }
    
    func test_textField_changeFromEditingToNoFocusWithMatch_shouldSetStateToSelectedCollapsed() {
        
        let (_, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .editing(.init("Армения", cursorPosition: 3)))
        textField.setState(to: .noFocus("Армения"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .selected(.am, listState: .expanded),
            .selected(.am, listState: .collapsed),
        ])
    }
    
    func test_textField_changeFromEditingToPlaceholder_shouldSetStateToCollapsed() {
        
        let (_, scheduler, spy, textField) = makeSUT(initialState: .collapsed)
        
        textField.setState(to: .editing(.init("Арм", cursorPosition: 3)))
        textField.setState(to: .editing(.init("", cursorPosition: 0)))
        textField.setState(to: .placeholder("A placeholder"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .expanded([.am]),
            .expanded(.allItems),
            .collapsed,
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Model,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: ValueSpy<State>,
        textField: TextFieldSpy<TestItem>
    ) {
        let textField = TextFieldSpy<TestItem>()
        let scheduler = DispatchQueue.test
        let sut = Model(
            initialState: initialState,
            items: .allItems,
            filterKeyPath: \.name,
            textField: textField,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(textField, file: file, line: line)
        
        return (sut, scheduler, spy, textField)
    }
}

// MARK: - DSL

private extension Model {
    
    func send(
        _ action: Action,
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) {
        send(action)
        scheduler.advance(by: duration)
    }
}

struct TestItem: Equatable {
    
    let name: String
}

extension TestItem {
    
    static let am: Self = .init(name: "Армения")
    static let az: Self = .init(name: "Азербайджан")
    static let il: Self = .init(name: "Израиль")
}

extension Array where Element == TestItem {
    
    static let allItems: Self = [.am, .az, .il]
}

func unimplemented<T>(_ message: String = "Unimplemented") -> T {
    
    fatalError(message)
}

extension Array {
    
    /// Returns filtered array elements. Nil or empty filtering text has no effect.
    /// - Parameters:
    ///   - text: Text to filter by. It has no effect if nil or empty.
    ///   - keyPath: A keyPath to use for comparison.
    /// - Returns: Array of filtered elements.
    func filtered(
        with text: String?,
        keyPath: KeyPath<Element, String>
    ) -> Self {
        
        guard let text, !text.isEmpty else {
            return self
        }
        
        return filter {
            
            $0[keyPath: keyPath]
                .localizedLowercase.hasPrefix(text.localizedLowercase)
        }
    }
}

final class ArrayExtensionsTests: XCTestCase {
    
    // MARK: - match
    
    func test_match_shouldReturnNilOnNoMatch() {
        
        let match = [TestItem].allItems.first(matching: "Эритрея", keyPath: \.name)
        
        XCTAssertNil(match)
    }
    
    func test_match_shouldReturnMatch() {
        
        let match = [TestItem].allItems.first(matching: "Армения", keyPath: \.name)
        
        XCTAssertEqual(match, .am)
    }
}

extension Array {
    
    func first(matching: String, keyPath: KeyPath<Element, String>) -> Element? {
        
        first { $0[keyPath: keyPath] == matching }
    }
}
