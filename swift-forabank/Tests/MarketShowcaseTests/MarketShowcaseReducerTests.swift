//
//  MarketShowcaseReducerTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import XCTest
import RxViewModel
import Combine

final class MarketShowcaseReducerTests: XCTestCase {
    
    func test_reduce_update_stateInflight_shouldStateNotChanged() {
        
        assertState(.update, on: .inflight)
    }
    
    func test_reduce_update_stateInflight_shouldDeliverNoEffect
    () {
        
        assert(.update, on: .inflight, effect: nil)
    }
    
    func test_reduce_update_stateLoaded_shouldStateToInflight() {
        
        assertState(.update, on: .loaded) {
            $0 = .inflight
        }
    }
    
    func test_reduce_update_stateLoaded_shouldDeliverLoadEffect
    () {
        
        assert(.update, on: .loaded, effect: .load)
    }
    
    func test_reduce_loaded_stateInflight_shouldStateToLoaded() {
        
        assertState(.loaded, on: .inflight) {
            $0 = .loaded
        }
    }
    
    func test_reduce_loaded_stateInflight_shouldDeliverNoEffect
    () {
        
        assert(.loaded, on: .inflight, effect: nil)
    }

    func test_reduce_loaded_stateLoaded_shouldStateNotChanged() {
        
        assertState(.loaded, on: .loaded)
    }
    
    func test_reduce_loaded_stateLoaded_shouldDeliverNoEffect
    () {
        
        assert(.loaded, on: .loaded, effect: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = MarketShowcaseReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        makeInformer: @escaping (String) -> Void = {_ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(makeInformer: makeInformer)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
