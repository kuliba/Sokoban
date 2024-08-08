//
//  OptionalSelectorReducerTests.swift
//
//
//  Created by Igor Malyarov on 08.08.2024.
//

import OptionalSelectorComponent
import XCTest

final class OptionalSelectorReducerTests: XCTestCase {
    
    // MARK: - select
    
    func test_deselect_shouldSetSelectionToNil() {
        
        let nonSelected = makeState(selected: makeItem())
        
        assert(nonSelected, event: .select(nil)) {
            
            $0.selected = nil
        }
    }
    
    func test_deselect_shouldDeliverNoEffect() {
        
        let nonSelected = makeState(selected: makeItem())
        
        assert(nonSelected, event: .select(nil), delivers: nil)
    }
    
    func test_select_shouldSetSelectionOnNonSelected() {
        
        let item = makeItem()
        let nonSelected = makeState(selected: nil)
        
        assert(nonSelected, event: .select(item)) {
            
            $0.selected = item
        }
    }
    
    func test_select_shouldDeliverNoEffectOnNonSelected() {
        
        let item = makeItem()
        let nonSelected = makeState(selected: nil)
        
        assert(nonSelected, event: .select(item), delivers: nil)
    }
    
    func test_select_shouldChangeSelectionOnSelected() {
        
        let (item, newItem) = (makeItem(), makeItem())
        let nonSelected = makeState(selected: item)
        
        assert(nonSelected, event: .select(newItem)) {
            
            $0.selected = newItem
        }
    }
    
    func test_select_shouldDeliverNoEffectOnSelected() {
        
        let (item, newItem) = (makeItem(), makeItem())
        let nonSelected = makeState(selected: item)
        
        assert(nonSelected, event: .select(newItem), delivers: nil)
    }
    
    // MARK: - search
    
    func test_search_shouldChangeSearchQueryAndFilteredItemsToAllOnEmptyQuery() {
        
        let items = makeItems(count: 5)
        let state = makeState(items: items, filtered: [], query: anyMessage())
        
        assert(state, event: .search("")) {
            
            $0.searchQuery = ""
            $0.filteredItems = items
        }
    }
    
    func test_search_shouldNotDeliverEffectOnEmpty() {
        
        assert(makeState(query: anyMessage()), event: .search(""), delivers: nil)
    }
    
    func test_search_shouldChangeSearchQueryAndSetFilteredItemsToPredicateMatching() {
        
        let items = makeItems("a", "aa", "ba", "bb", "c")
        let state = makeState(items: items, filtered: [], query: anyMessage())
        let sut = makeSUT(predicate: { $0.value.contains($1) })
        
        assert(sut: sut, state, event: .search("a")) {
            
            $0.searchQuery = "a"
            $0.filteredItems = self.makeItems("a", "aa", "ba")
        }
    }
    
    func test_search_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .search(anyMessage()), delivers: nil)
    }
    
    // MARK: - toggleOptions
    
    func test_toggleOptions_shouldSetShowingOptionsFlagToTrueOnFalse() {
        
        assert(makeState(isShowingOptions: false), event: .toggleOptions) {
            
            $0.isShowingOptions = true
        }
    }
    
    func test_toggleOptions_shouldNotDeliverEffectOnFalse() {
        
        assert(makeState(isShowingOptions: false), event: .toggleOptions, delivers: nil)
    }
    
    func test_toggleOptions_shouldSetShowingOptionsFlagToFalseOnTrue() {
        
        assert(makeState(isShowingOptions: true), event: .toggleOptions) {
            
            $0.isShowingOptions = false
        }
    }
    
    func test_toggleOptions_shouldNotDeliverEffectOnTrue() {
        
        assert(makeState(isShowingOptions: true), event: .toggleOptions, delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OptionalSelectorReducer<Item>
    
    private func makeSUT(
        predicate: @escaping (Item, String) -> Bool = { _,_ in true },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(predicate: predicate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        items: [Item]? = nil,
        filtered filteredItems: [Item] = [],
        isShowingOptions: Bool = false,
        selected: Item? = nil,
        query: String = ""
    ) -> SUT.State {
        
        return .init(
            items: items ?? makeItems(count: 3), 
            filteredItems: filteredItems,
            isShowingOptions: isShowingOptions,
            selected: selected,
            searchQuery: query
        )
    }
    
    private func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
    
    private func makeItems(_ values: String...) -> [Item] {
        
        values.map { makeItem($0) }
    }
    
    private func makeItems(
        count: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [Item] {
        
        let items = (0..<count).map { _ in makeItem() }
        XCTAssertEqual(items.count, count, file: file, line: line)
        return items
    }
    
    private struct Item: Equatable {
        
        let value: String
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
