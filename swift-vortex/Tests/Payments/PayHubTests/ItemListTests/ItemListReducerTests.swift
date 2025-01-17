//
//  ItemListReducerTests.swift
//  
//
//  Created by Igor Malyarov on 17.01.2025.
//

import PayHub
import XCTest

final class ItemListReducerTests: ItemListTests {
    
    // MARK: - load
    
    func test_load_shouldNotChangeEmptyStateOnZeroPlaceholderCount() {
        
        let state = makeState()
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .load)
    }
    
    func test_load_shouldRemoveSuffixOnZeroPlaceholderCount() {
        
        let item = makeItem()
        let state = makeState(prefix: [item], suffix: [makeItem()])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item])
        }
    }
    
    func test_load_shouldSetPlaceholderSuffixOnEmptySuffix() {
        
        let state = makeState()
        let sut = makeSUT(placeholderIDs: 4, 5)
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(suffix: [.placeholder(4), .placeholder(5)])
        }
    }
    
    func test_load_shouldSetPlaceholderSuffixOnNonEmptySuffix() {
        
        let state = makeState(suffix: [makeItem()])
        let sut = makeSUT(placeholderIDs: 3, 2, 1)
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(suffix: [.placeholder(3), .placeholder(2), .placeholder(1)])
        }
    }
    
    func test_load_shouldDeliverEffect() {
        
        let state = makeState()
        let sut = makeSUT(placeholderIDs: 3)
        
        assert(sut: sut, state, event: .load, delivers: .load)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldNotChangeEmptyStateOnNil() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded(nil))
    }
    
    func test_loaded_shouldResetSuffixOnNil() {
        
        let item = makeItem()
        let state = makeState(prefix: [], suffix: [item])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded(nil)) {
            
            $0 = self.makeState()
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnNil() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded(nil), delivers: nil)
    }
    
    func test_loaded_shouldSetEmptyOnEmptyWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([])) {
            
            $0 = self.makeState(prefix: [], suffix: [])
            XCTAssertNoDiff($0.items, [])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmptyWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetOneOnEmptyWithPrefixOfOne() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([])) {
            
            $0 = self.makeState(prefix: [item], suffix: [])
            XCTAssertNoDiff($0.items, [item])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmptyWithPrefixOfOne() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetTwoOnEmptyWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([])) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [])
            XCTAssertNoDiff($0.items, [item1, item2])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmptyWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetOneOnOneWithEmptyPrefix() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let identified = makeIdentified(id: id, element: element)
        let state = makeState(prefix: [])
        let sut = makeSUT(makeID: { id })
        
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [], suffix: [.element(identified)])
            XCTAssertNoDiff($0.items, [.element(identified)])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddOneOnOneWithPrefixOfOne() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let identified = makeIdentified(id: id, element: element)
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(makeID: { id })
        
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [item], suffix: [.element(identified)])
            XCTAssertNoDiff($0.items, [item, .element(identified)])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneWithPrefixOfOne() {
        
        let state = makeState(prefix: [makeItem()])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddOneOnOneWithPrefixOfTwo() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let identified = makeIdentified(id: id, element: element)
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(makeID: { id })
        
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [.element(identified)])
            XCTAssertNoDiff($0.items, [item1, item2, .element(identified)])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldSetTwoOnTwoWithEmptyPrefix() {
        
        let (id1, id2) = (1, 2)//(makePlaceholderID(), makePlaceholderID())
        let (element1, element2) = (makeElement(), makeElement())
        let identified1 = makeIdentified(id: id1, element: element1)
        let identified2 = makeIdentified(id: id2, element: element2)
        let state = makeState(prefix: [])
        var ids = [id1, id2]
        let sut = makeSUT(makeID: { ids.removeFirst() })
        
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [], suffix: [
                .element(identified1),
                .element(identified2)
            ])
            XCTAssertNoDiff($0.items, [
                .element(identified1),
                .element(identified2)
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([makeElement(), makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddTwoOnTwoWithPrefixOfOne() {
        
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let (element1, element2) = (makeElement(), makeElement())
        let identified1 = makeIdentified(id: id1, element: element1)
        let identified2 = makeIdentified(id: id2, element: element2)
        let item = makeItem()
        let state = makeState(prefix: [item])
        var ids = [id1, id2]
        let sut = makeSUT(makeID: { ids.removeFirst() })
        
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [item], suffix: [
                .element(identified1),
                .element(identified2)
            ])
            XCTAssertNoDiff($0.items, [
                item,
                .element(identified1),
                .element(identified2)
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoWithPrefixOfOne() {
        
        let state = makeState(prefix: [makeItem()])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([makeElement(), makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddOneOnTwoWithPrefixOfTwo() {
        
        let id = makePlaceholderID()
        let (element1, element2) = (makeElement(), makeElement())
        let identified1 = makeIdentified(id: id, element: element1)
        let identified2 = makeIdentified(id: id, element: element2)
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(makeID: { id })
        
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [
                .element(identified1),
                .element(identified2)
            ])
            XCTAssertNoDiff($0.items, [
                item1,
                item2,
                .element(identified1),
                .element(identified2)
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .loaded([makeElement(), makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldReusePlaceholderID() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let identified = makeIdentified(id: id, element: element)
        var state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: id)
        
        (state, _) = sut.reduce(state, .load)
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [], suffix: [.element(identified)])
        }
    }
    
    func test_loaded_shouldReusePlaceholderIDs() {
        
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let (element1, element2) = (makeElement(), makeElement())
        let identified1 = makeIdentified(id: id1, element: element1)
        let identified2 = makeIdentified(id: id2, element: element2)
        var state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: id1, id2)
        
        (state, _) = sut.reduce(state, .load)
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [], suffix: [
                .element(identified1),
                .element(identified2)
            ])
        }
    }
    
    // MARK: - reload
    
    func test_reload_shouldNotChangeEmptyStateOnZeroPlaceholderCount() {
        
        let state = makeState()
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .reload)
    }
    
    func test_reload_shouldRemoveSuffixOnZeroPlaceholderCount() {
        
        let item = makeItem()
        let state = makeState(prefix: [item], suffix: [makeItem()])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .reload) {
            
            $0 = self.makeState(prefix: [item])
        }
    }
    
    func test_reload_shouldSetPlaceholderSuffixOnEmptySuffix() {
        
        let state = makeState()
        let sut = makeSUT(placeholderIDs: 4, 5)
        
        assert(sut: sut, state, event: .reload) {
            
            $0 = self.makeState(suffix: [.placeholder(4), .placeholder(5)])
        }
    }
    
    func test_reload_shouldSetPlaceholderSuffixOnNonEmptySuffix() {
        
        let state = makeState(suffix: [makeItem()])
        let sut = makeSUT(placeholderIDs: 3, 2, 1)
        
        assert(sut: sut, state, event: .reload) {
            
            $0 = self.makeState(suffix: [.placeholder(3), .placeholder(2), .placeholder(1)])
        }
    }
    
    func test_reload_shouldDeliverEffect() {
        
        let state = makeState()
        let sut = makeSUT(placeholderIDs: 3)
        
        assert(sut: sut, state, event: .reload, delivers: .reload)
    }
    
    // MARK: - updateState
    
    func test_updateState_shouldNotChangeEmptyState() {
        
        assert(sut: makeSUT(), makeState(), event: .update(state: .completed, forID: "cbd"))
    }

    func test_updateState_shouldNotChangeStateOnMismatchingEntityID() {

        let state = makeState(suffix: [
            element(id: 1, value: "abc", state: .pending)
        ])
        
        assert(sut: makeSUT(), state, event: .update(state: .completed, forID: anyMessage()))
    }
    
    func test_updateState_shouldUpdateStateOfMatchingElement() {
        
        let state = makeState(suffix: [
            element(id: 1, value: "abc", state: .pending)
        ])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .update(state: .failed, forID: "abc")) {
            
            $0 = self.makeState(suffix: [
                self.element(id: 1, value: "abc", state: .failed)
            ])
        }
    }
    
    func test_updateState_shouldUpdateStateOfMatchingElement2() {
        
        let state = makeState(suffix: [
            element(id: 1, value: "abc", state: .pending),
            element(id: 2, value: "cbd", state: .loading)
        ])
        let sut = makeSUT()
        
        assert(sut: sut, state, event: .update(state: .completed, forID: "cbd")) {
            
            $0 = self.makeState(suffix: [
                self.element(id: 1, value: "abc", state: .pending),
                self.element(id: 2, value: "cbd", state: .completed)
            ])
        }
    }
    
    private func element(
        id: ID,
        value: String,
        state: LoadState
    ) -> Item {
        
        let element = makeElement(entity: makeEntity(value), state: state)
        return .element(makeIdentified(id: id, element: element))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Domain.Reducer
    
    private func makeSUT(
        makeID: @escaping () -> ID = { .random(in: 1...100) },
        placeholderIDs: ID...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            makeID: makeID,
            makePlaceholders: { placeholderIDs }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        prefix: [SUT.State.Item] = [],
        suffix: [SUT.State.Item] = []
    ) -> SUT.State {
        
        return .init(prefix: prefix, suffix: suffix)
    }
    
    @discardableResult
    private func assert(
        sut: SUT,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
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
        sut: SUT,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
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
