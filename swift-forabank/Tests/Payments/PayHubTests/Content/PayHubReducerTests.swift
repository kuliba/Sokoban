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
    
    func test_load_shouldSetStateToNil() {
        
        assert(makeState([.exchange]), event: .load) {
            
            $0 = .none
        }
    }
    
    func test_load_shouldDeliverLoadEffect() {
        
        assert(makeState([.exchange]), event: .load, delivers: .load)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldSetTemplatesWithExchangeOnEmpty() {
        
        assert(.none, event: .loaded([])) {
            
            $0 = .init(items: [.templates, .exchange])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmpty() {
        
        assert(.none, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetTemplatesWithExchangeAndOneLatestOnOneLatest() {
        
        let latest = makeLatest()
        
        assert(.none, event: .loaded([latest])) {
            
            $0 = .init(items: [.templates, .exchange, .latest(latest)])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneLatest() {
        
        let latest = makeLatest()
        
        assert(.none, event: .loaded([latest]), delivers: nil)
    }
    
    func test_loaded_shouldSetTemplatesWithExchangeAndTwoLatestOnTwoLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        
        assert(.none, event: .loaded([latest1, latest2])) {
            
            $0 = .init(items: [.templates, .exchange, .latest(latest1), .latest(latest2)])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        
        assert(.none, event: .loaded([latest1, latest2]), delivers: nil)
    }
    
    // MARK: - select
    
    func test_select_shouldNotChangeNilState() {
        
        assert(.none, event: .select(.exchange))
    }
    
    func test_select_shouldNotDeliverEffectOnNilState() {
        
        assert(.none, event: .select(.exchange), delivers: .none)
    }
    
    func test_select_shouldChangeNonNilState() {
        
        assert(makeState([.templates]), event: .select(.templates)) {
            
            $0?.selected = .templates
        }
    }
    
    func test_select_shouldNotDeliverEffectOnNonNilState() {
        
        assert(makeState([.templates]), event: .select(.templates), delivers: .none)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubReducer<Latest>
    private typealias Item = PayHubItem<Latest>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        _ items: [Item],
        selected: Item? = nil
    ) -> SUT.State {
        
        return .init(items: items, selected: selected)
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
