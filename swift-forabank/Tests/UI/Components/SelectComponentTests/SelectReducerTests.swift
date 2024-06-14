//
//  SelectReducerTests.swift
//
//
//  Created by Дмитрий Савушкин on 13.06.2024.
//

import SelectComponent
import RxViewModel
import XCTest
import SwiftUI

extension SelectReducer: Reducer {}

final class SelectReducerTests: XCTestCase {
    
    func test_reduce_select_shouldReturnCollapseState() {
        
        let sut = makeSUT()
        let state = makeState(state: makeCollapsedState())
        
        assert(sut: sut, .chevronTapped(options: nil, selectOption: nil), on: state) {state in 
            state.state = .expanded(selectOption: nil, options: [], searchText: nil)
        }
    }
    
    func test_reduce_select_shouldReturnExpanded() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeExpandedState())
        
        assert(sut: sut, .chevronTapped(options: nil, selectOption: nil), on: state) { state in
            
            state.state = .collapsed(option: nil, options: nil)
        }
    }
    
    
    func test_reduce_select_optionTapped_shouldReturnCollapsed() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeExpandedState())
        let option: SelectState.Option = .init(id: "id", title: "title", isSelected: true)
        
        assert(sut: sut, .optionTapped(option), on: state) { state in
            
            state.state = .collapsed(option: option, options: nil)
        }
    }
    
    func test_reduce_select_search_shouldReturnExpanded() {
        
        let sut = makeSUT()
        
        let state = makeState(state: makeCollapsedState())
        
        assert(sut: sut, .search("text"), on: state) { state in
            
            state.state = .expanded(selectOption: nil, options: [], searchText: "text")
        }
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
    
    typealias State = SelectUIState
    typealias Event = SelectReducer.Event
    typealias Effect = SelectEffectTest
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: ((_ state: inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
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

enum SelectEffectTest: Equatable {}

extension SelectEvent {
    
    var testState: SelectEventTest {
        
        switch self {
        case .chevronTapped:
            return .chevronTapped
        case .optionTapped:
            return .optionTapped
        case .search:
            return .search
        }
    }
}

enum SelectEventTest: Equatable {
    
    case chevronTapped
    case optionTapped
    case search
}

