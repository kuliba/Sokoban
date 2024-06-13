//
//  SelectReducerTests.swift
//
//
//  Created by Дмитрий Савушкин on 13.06.2024.
//

import SelectComponent
import XCTest
import SwiftUI

final class SelectReducerTests: XCTestCase {
    
    func test_reduce_select_shouldReturnCollapseState() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeExpandedState())
        let newState = sut.reduce(
            state, .chevronTapped(options: nil, selectOption: nil)
        )
        
        XCTAssertEqual(newState.0.state.testState, .collapsed)
    }
    
    func test_reduce_select_shouldReturnExpanded() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeCollapsedState())
        let newState = sut.reduce(
            state, .chevronTapped(options: nil, selectOption: nil)
        )
        
        XCTAssertEqual(newState.0.state.testState, .expanded)
    }
    
    
    func test_reduce_select_optionTapped_shouldReturnCollapsed() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeExpandedState())
        let newState = sut.reduce(
            state, .optionTapped(.init(id: "id", title: "title", isSelected: true))
        )
        
        XCTAssertEqual(newState.0.state.testState, .collapsed)
    }
    
    func test_reduce_select_search_shouldReturnExpanded() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeCollapsedState())
        let newState = sut.reduce(
            state, .search("text")
        )
        
        XCTAssertEqual(newState.0.state.testState, .expanded)
    }
    
    func test_filteredOption_shouldReturnOption() {
        
        let sut = SelectState.expanded(
            selectOption: nil,
            options: [
                .init(id: "id", title: "title", isSelected: true),
                .init(id: "id2", title: "1", isSelected: false)
            ],
            searchText: "title"
        )
        
        XCTAssertEqual(
            sut.filteredOption,
            [.init(id: "id", title: "title", isSelected: true)]
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SelectReducer
    private typealias Spy = CallSpy<SUT.State>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeExpandedState() -> SelectState {
        .expanded(
            selectOption: nil,
            options: [.init(id: "", title: "title", isSelected: false)],
            searchText: nil
        )
    }
    
    private func makeCollapsedState() -> SelectState {
        
        .collapsed(option: nil, options: nil)
    }
    
    private func makeState(state: SelectState) -> SUT.State {
        
        .init(
            image: .init(systemName: ""),
            state: state
        )
    }
}

extension SelectState {
    
    var testState: SelectStateTest {
        
        .init(selectState: self)
    }
}

enum SelectStateTest: Equatable {
    
    case collapsed
    case expanded
    
    init(selectState: SelectState) {
        
        if case .collapsed = selectState {
            self = .collapsed
        } else {
            self = .expanded
        }
    }
}

