//
//  ItemSelectModelReduceTests.swift
//  
//
//  Created by Igor Malyarov on 02.06.2023.
//

import Combine
import TextFieldDomain
import XCTest

final class ItemSelectModelReduceTests: XCTestCase {
    
    // MARK: - select
    
    func test_select_shouldReturn_selectedCollapsed_select_fromSelectedExpanded() throws {
        
        let state: State = .selected(.az, listState: .expanded)
        let action: Action = .select(.am)
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .collapsed))
        XCTAssertNoDiff(sideEffect, .select(.am))
    }
    
    func test_select_shouldReturn_selectedExpanded_fromSelectedCollapsed() throws {
        
        let state: State = .selected(.az, listState: .collapsed)
        let action: Action = .select(.am)
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .expanded))
        XCTAssertNoDiff(sideEffect, nil)
    }
    
    func test_select_shouldThrowFromCollapsedState() throws {
        
        let state: State = .collapsed
        let action: Action = .select(.am)
        
        XCTAssertThrowsError(
            _ = try makeSUT()(state, action)
        )
    }
    
    func test_select_shouldReturn_selectedCollapsed_select_fromExpandedState() throws {
        
        let state: State = .expanded(.allItems)
        let action: Action = .select(.am)
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .collapsed))
        XCTAssertNoDiff(sideEffect, .select(.am))
    }
    
    func test_select_shouldFromSelectedCollapsedToExpanded() throws {
        
        let state: State = .selected(.az, listState: .collapsed)
        let action: Action = .select(.am)
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .expanded))
        XCTAssertNoDiff(sideEffect, nil)
    }
    
    
    // MARK: - toggleListVisibility
    
    func test_toggleListVisibility_shouldChangeExpandedStateToCollapsed_finishEditing() throws {
        
        let state: State = .expanded(.allItems)
        let action: Action = .toggleListVisibility
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .collapsed)
        XCTAssertNoDiff(sideEffect, .finishEditing)
    }
    
    
    func test_toggleListVisibility_shouldChangeCollapsedStateToExpanded_startEditing() throws {
        
        let state: State = .collapsed
        let action: Action = .toggleListVisibility
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .expanded(.allItems))
        XCTAssertNoDiff(sideEffect, .startEditing)
    }
    
    func test_toggleListVisibility_shouldChangeSelectedCollapsedStateToSelectedExpanded_startEditing() throws {
        
        let state: State = .selected(.am, listState: .collapsed)
        let action: Action = .toggleListVisibility
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .expanded))
        XCTAssertNoDiff(sideEffect, .startEditing)
    }
    
    func test_toggleListVisibility_shouldNotChangeSelectedCollapsedState_startEditing() throws {
        
        let state: State = .selected(.am, listState: .collapsed)
        let action: Action = .toggleListVisibility
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .expanded))
        XCTAssertNoDiff(sideEffect, .startEditing)
    }
    
    func test_toggleListVisibility_shouldChangeSelectedExpandedStateToSelectedCollapsed_finishEditing() throws {
        
        let state: State = .selected(.am, listState: .expanded)
        let action: Action = .toggleListVisibility
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .selected(.am, listState: .collapsed))
        XCTAssertNoDiff(sideEffect, .finishEditing)
    }
    
    // MARK: - filterList
    
    func test_filterList_shouldThrowOnCollapsed() throws {
        
        let state: State = .collapsed
        let action: Action = .filterList(nil)
        
        XCTAssertThrowsError(
            _ = try makeSUT()(state, action)
        )
    }
    
    func test_filterList_shouldThrowOnSelectedCollapsed() throws {
        
        let state: State = .selected(.am, listState: .collapsed)
        let action: Action = .filterList(nil)
        
        XCTAssertThrowsError(
            _ = try makeSUT()(state, action)
        )
    }
    
    func test_filterList_shouldThrowOOnSelectedExpanded() throws {
        
        let state: State = .selected(.am, listState: .expanded)
        let action: Action = .filterList(nil)
        
        XCTAssertThrowsError(
            _ = try makeSUT()(state, action)
        )
    }
    
    func test_filterList_shouldNotFilterItemsOnExpanded_nilText() throws {
        
        let state: State = .expanded(.allItems)
        let action: Action = .filterList(nil)
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .expanded(.allItems))
        XCTAssertNoDiff(sideEffect, nil)
    }
    
    func test_filterList_shouldNotFilterItemsOnExpanded_emptyText() throws {
        
        let state: State = .expanded(.allItems)
        let action: Action = .filterList("")
        
        let (newState, sideEffect) = try makeSUT()(state, action)
        
        XCTAssertNoDiff(newState, .expanded(.allItems))
        XCTAssertNoDiff(sideEffect, nil)
    }
    
    private typealias ViewModel = ItemSelectModel<TestItem>
    private typealias State = ViewModel.State
    private typealias Action = ViewModel.Action
    private typealias SideEffect = ViewModel.SideEffect
    
    private func makeSUT(
        _ items: [TestItem] = .allItems,
        filterKeyPath: KeyPath<TestItem, String> = \.name,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (State, Action) throws -> (State, SideEffect?) {
        
        return { state, action in
            
            try ViewModel.reduce(state, with: action, items: items, filterKeyPath: filterKeyPath)
        }
    }
}
