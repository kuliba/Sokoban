//
//  AsyncPickerReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

import ForaTools
import XCTest

final class AsyncPickerReducerTests: AsyncPickerTests {
    
    // MARK: - load
    
    func test_load_shouldNotChangeStateOnIsLoadingTrue() {
        
        assert(makeState(isLoading: true), event: .load)
    }
    
    func test_load_shouldNotDeliverEffectOnIsLoadingTrue() {
        
        assert(makeState(isLoading: true), event: .load, delivers: nil)
    }
    
    func test_load_shouldSetIsLoadingToTrue() {
        
        assert(makeState(), event: .load) {
            
            $0.isLoading = true
        }
    }
    
    func test_load_shouldDeliverEffectWithPayload() {
        
        let payload = makePayload()
        
        assert(makeState(payload: payload), event: .load, delivers: .load(payload))
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldNotChangeStateOnIsLoadingFalse_zeroItems() {
        
        let items = makeItems(count: 0)
        
        assert(makeState(isLoading: false), event: .loaded(items))
    }
    
    func test_loaded_shouldNotDeliverEffectOnIsLoadingFalse_zeroItems() {
        
        let items = makeItems(count: 0)
        
        assert(makeState(isLoading: false), event: .loaded(items), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateOnIsLoadingTrue_zeroItems() {
        
        let items = makeItems(count: 0)
        
        assert(makeState(isLoading: true), event: .loaded(items)) {
            
            $0.isLoading = false
            $0.items = []
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnIsLoadingTrue_zeroItems() {
        
        let items = makeItems(count: 0)
        
        assert(makeState(isLoading: true), event: .loaded(items), delivers: nil)
    }
    
    func test_loaded_shouldNotChangeStateOnIsLoadingFalse_oneItem() {
        
        let items = makeItems(count: 1)
        
        assert(makeState(isLoading: false), event: .loaded(items))
    }
    
    func test_loaded_shouldNotDeliverEffectOnIsLoadingFalse_oneItem() {
        
        let items = makeItems(count: 1)
        
        assert(makeState(isLoading: false), event: .loaded(items), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateOnIsLoadingTrue_oneItem() {
        
        let items = makeItems(count: 1)
        
        assert(makeState(isLoading: true), event: .loaded(items)) {
            
            $0.isLoading = false
            $0.items = items
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnIsLoadingTrue_oneItem() {
        
        let items = makeItems(count: 1)
        
        assert(makeState(isLoading: true), event: .loaded(items), delivers: nil)
    }
    
    func test_loaded_shouldNotChangeStateOnIsLoadingFalse_twoItems() {
        
        let items = makeItems(count: 2)
        
        assert(makeState(isLoading: false), event: .loaded(items))
    }
    
    func test_loaded_shouldNotDeliverEffectOnIsLoadingTrue_twoItems() {
        
        let items = makeItems(count: 2)
        
        assert(makeState(isLoading: true), event: .loaded(items), delivers: nil)
    }
    
    func test_loaded_shouldChangeStateOnIsLoadingTrue_twoItems() {
        
        let items = makeItems(count: 2)
        
        assert(makeState(isLoading: true), event: .loaded(items)) {
            
            $0.isLoading = false
            $0.items = items
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnIsLoadingFalse_twoItems() {
        
        let items = makeItems(count: 2)
        
        assert(makeState(isLoading: false), event: .loaded(items), delivers: nil)
    }
    
    // MARK: - select
    
    func test_select_shouldNotChangeStateNilItems() {
        
        assert(makeState(items: nil), event: .select(makeItem()))
    }
    
    func test_select_shouldNotDeliverEffectNilItems() {
        
        assert(makeState(items: nil), event: .select(makeItem()), delivers: nil)
    }
    
    func test_select_shouldNotChangeStateEmptyItems() {
        
        assert(makeState(items: []), event: .select(makeItem()))
    }
    
    func test_select_shouldNotDeliverEffectEmptyItems() {
        
        assert(makeState(items: []), event: .select(makeItem()), delivers: nil)
    }
    
    func test_select_shouldChangeStateOnExistingSingleItem() {
        
        let item = makeItem()
        
        assert(makeState(items: [item]), event: .select(item)) {
            
            $0.isLoading = true
        }
    }
    
    func test_select_shouldDeliverEffectOnExistingSingleItem() {
        
        let item = makeItem()
        
        assert(makeState(items: [item]), event: .select(item), delivers: .select(item))
    }
    
    func test_select_shouldChangeStateOnOneOfExistingItems() {
        
        let item = makeItem()
        
        assert(makeState(items: [item, makeItem()]), event: .select(item)) {
            
            $0.isLoading = true
        }
    }
    
    func test_select_shouldDeliverEffectOnOneOfExistingItems() {
        
        let item = makeItem()
        
        assert(makeState(items: [item, makeItem()]), event: .select(item), delivers: .select(item))
    }
    
    // MARK: - response
    
    func test_response_shouldSetResponse() {
        
        let response = makeResponse()
        
        assert(makeState(isLoading: true), event: .response(response)) {
            
            $0.isLoading = false
            $0.response = response
        }
    }
    
    func test_response_shouldNotDeliverEffect() {
        
        let response = makeResponse()
        
        assert(makeState(), event: .response(response), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AsyncPickerReducer<Payload, Item, Response>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        payload: Payload? = nil,
        isLoading: Bool = false,
        items: [Item]? = nil
    ) -> SUT.State {
        
        return .init(payload: payload ?? makePayload(), isLoading: isLoading, items: items)
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
