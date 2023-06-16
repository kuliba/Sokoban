//
//  TextFieldItemSelectStatePublisherTests.swift
//  
//
//  Created by Igor Malyarov on 02.06.2023.
//

import Combine
import TextFieldDomain
import XCTest

final class TextFieldItemSelectStatePublisherTests: XCTestCase {
    
    func test_itemSelectStatePublisher_shouldMapValues() {
        
        let (sut, spy) = makeSUT()
        
        sut.setState(to: .placeholder("A placeholder"))
        sut.setState(to: .editing(.empty))
        sut.setState(to: .editing(.init("z", cursorPosition: 1)))
        sut.setState(to: .editing(.init("", cursorPosition: 1)))
        sut.setState(to: .editing(.init("А", cursorPosition: 1)))
        sut.setState(to: .editing(.init("Арм", cursorPosition: 3)))
        sut.setState(to: .editing(.init("Армения", cursorPosition: 7)))
        sut.setState(to: .noFocus("Армения"))
        sut.setState(to: .editing(.init("Армения", cursorPosition: 1)))
        sut.setState(to: .editing(.init("", cursorPosition: 1)))
        sut.setState(to: .placeholder("A placeholder"))

        XCTAssertNoDiff(spy.values, [
            .collapsed,
            .expanded(.allItems),
            .expanded([]),
            .expanded(.allItems),
            .expanded([.am, .az]),
            .expanded([.am]),
            .selected(.am, listState: .expanded),
            .selected(.am, listState: .collapsed),
            .selected(.am, listState: .expanded),
            .expanded(.allItems),
            .collapsed
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        _ items: [TestItem] = .allItems,
        filterKeyPath: KeyPath<TestItem, String> = \.name,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: TextFieldMock,
        spy: ValueSpy<ItemSelectModel<TestItem>.State>
    ) {
        let sut = TextFieldMock()
        let spy = ValueSpy(
            sut.itemSelectStatePublisher(
                items,
                filterKeyPath: filterKeyPath
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class TextFieldMock: TextField {
        
        private let stateSubject = PassthroughSubject<TextFieldState, Never>()
        
        var textFieldStatePublisher: AnyPublisher<TextFieldState, Never> {
            
            stateSubject.eraseToAnyPublisher()
        }
        
        func send(_ action: TextFieldAction<TestItem>) {}
        
        func setState(to state: TextFieldState) {
            
            stateSubject.send(state)
        }
    }
}
