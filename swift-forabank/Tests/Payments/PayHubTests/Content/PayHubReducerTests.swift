//
//  PayHubReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import PayHub
import XCTest

final class PayHubReducerTests: PayHubTests {
    
    // MARK: - load
    
    func test_load_shouldNotChangePlaceholderLoadStateSelectedNil() {
        
        let state = makePlaceholderState(selected: nil)
        
        assert(state, event: .load)
    }
    
    func test_load_shouldNotDeliverLoadEffectOnPlaceholderLoadStateSelectedNil() {
        
        let state = makePlaceholderState(selected: nil)
        
        assert(state, event: .load, delivers: nil)
    }
    
    func test_load_shouldNotChangePlaceholderLoadStateSelectedNonNil() {
        
        let state = makePlaceholderState(selected: .exchange)
        
        assert(state, event: .load)
    }
    
    func test_load_shouldNotDeliverLoadEffectOnPlaceholderLoadStateSelectedNonNil() {
        
        let state = makePlaceholderState(selected: .exchange)
        
        assert(state, event: .load, delivers: nil)
    }
    
    func test_load_shouldChangeLoadedStateSelectedNilToPlaceholder() {
        
        let ids = makeIDs(count: 9)
        let state = makeLoadedState(selected: nil)
        let sut = makeSUT(ids: ids)
        
        assert(sut: sut, state, event: .load) {
            
            $0.loadState = .placeholders(ids)
        }
    }
    
    func test_load_shouldDeliverLoadEffectOnLoadedStateSelectedNil() {
        
        let state = makeLoadedState(selected: nil)
        
        assert(state, event: .load, delivers: .load)
    }
    
    func test_load_shouldChangeLoadedStateSelectedNonNilToPlaceholderSelectedNil() {
        
        let ids = makeIDs(count: 9)
        let state = makeLoadedState(selected: .exchange)
        let sut = makeSUT(ids: ids)
        
        assert(sut: sut, state, event: .load) {
            
            $0.loadState = .placeholders(ids)
            $0.selected = nil
        }
    }
    
    func test_load_shouldDeliverLoadEffectOnLoadedStateSelectedNonNil() {
        
        let state = makeLoadedState(selected: .exchange)
        
        assert(state, event: .load, delivers: .load)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldSetEmptyOnEmpty() {
        
        assert(makePlaceholderState(), event: .loaded([])) {
            
            $0.loadState = .loaded([])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmpty() {
        
        assert(makePlaceholderState(), event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetOneLatestOnOneLatest() {
        
        let ids = makeIDs(count: 3)
        let state = makePlaceholderState(ids: ids)
        let latest = makeLatest()
        
        assert(state, event: .loaded([latest])) {
            
            $0.loadState = .loaded([
                .init(id: ids[0], element: latest)
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneLatest() {
        
        let latest = makeLatest()
        let state = makePlaceholderState()
        
        assert(state, event: .loaded([latest]), delivers: nil)
    }
    
    func test_loaded_shouldSetTwoLatestOnTwoLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let ids = makeIDs(count: 3)
        let state = makePlaceholderState(ids: ids)
        
        assert(state, event: .loaded([latest1, latest2])) {
            
            $0.loadState = .loaded([
                .init(id: ids[0], element: latest1),
                .init(id: ids[1], element: latest2),
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let state = makePlaceholderState()
        
        assert(state, event: .loaded([latest1, latest2]), delivers: nil)
    }
    
    func test_loaded_shouldNotChangeLoadedState() {
        
        assert(makeLoadedState([], selected: nil), event: .loaded([]))
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadedState() {
        
        assert(makeLoadedState([], selected: nil), event: .loaded([]), delivers: nil)
    }
    
    // MARK: - select
    
    func test_select_shouldChangePlaceholderStateSelectedNil() {
        
        assert(makePlaceholderState(), event: .select(.templates)) {
            
            $0.selected = .templates
        }
    }
    
    func test_select_shouldNotDeliverEffectOnPlaceholderStateSelectedNil() {
        
        assert(makePlaceholderState(), event: .select(.exchange), delivers: .none)
    }
    
    func test_select_shouldChangePlaceholderStateSelectedNonNil() {
        
        assert(makePlaceholderState(selected: .exchange), event: .select(.templates)) {
            
            $0.selected = .templates
        }
    }
    
    func test_select_shouldNotDeliverEffectOnPlaceholderStateSelectedNonNil() {
        
        assert(makePlaceholderState(selected: .exchange), event: .select(.templates), delivers: .none)
    }
    
    func test_select_shouldChangeLoadedStateSelectionNil() {
        
        assert(makeLoadedState(selected: nil), event: .select(.templates)) {
            
            $0.selected = .templates
        }
    }
    
    func test_select_shouldNotDeliverEffectOnLoadedStateSelectionNil() {
        
        assert(makeLoadedState(selected: nil), event: .select(.templates), delivers: .none)
    }
    
    func test_select_shouldChangeLoadedStateSelectionNonNil() {
        
        assert(makeLoadedState(selected: .exchange), event: .select(.templates)) {
            
            $0.selected = .templates
        }
    }
    
    func test_select_shouldNotDeliverEffectOnLoadedStateSelectionNonNil() {
        
        assert(makeLoadedState(selected: .exchange), event: .select(.templates), delivers: .none)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubReducer<Latest>
    private typealias Item = PayHubItem<Latest>
    private typealias ID = UUID
    
    private func makeSUT(
        ids: [UUID] = [.init(), .init(), .init(), .init()],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(makePlaceholders: { ids })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makePlaceholderState(
        ids: [UUID]? = nil,
        selected: Item? = nil
    ) -> SUT.State {
        
        return .init(loadState: .placeholders(ids ?? makeIDs(count: 4)), selected: selected)
    }
    
    private func makeLoadedState(
        _ loaded: [Identified<UUID, PayHubTests.Latest>] = [],
        selected: Item? = nil
    ) -> SUT.State {
        
        return .init(loadState: .loaded(loaded), selected: selected)
    }
    
    private func makeID(
        _ value: UUID = .init()
    ) -> ID {
        
        return value
    }
    
    private func makeIDs(
        count: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [ID] {
        
        let ids = (0..<count).map { _ in makeID() }
        XCTAssertEqual(ids.count, count, file: file, line: line)
        return ids
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
