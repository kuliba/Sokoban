//
//  MarketShowcaseReducerTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import XCTest
import RxViewModel
import Combine
import MarketShowcase

final class MarketShowcaseReducerTests: XCTestCase {
    
   /* func test_reduce_update_stateInflight_shouldStateNotChanged() {
        
        assertState(.update, on: .init(status: .inflight))
    }
    
    func test_reduce_update_stateInflight_shouldDeliverNoEffect
    () {
        
        assert(.update, on: .init(status: .inflight), effect: nil)
    }
    
    func test_reduce_update_stateLoaded_shouldStateToInflight() {
        
        assertState(.update, on: .init(status: .loaded)) {
            $0.status = .inflight
        }
    }
    
    func test_reduce_update_stateLoaded_shouldDeliverLoadEffect
    () {
        
        assert(.update, on: .init(status: .loaded), effect: .load)
    }
    
    func test_reduce_loaded_stateInflight_shouldStateToLoaded() {
        
        assertState(.loaded, on: .init(status: .inflight)) {
            $0.status = .loaded
        }
    }
    
    func test_reduce_loaded_stateInflight_shouldDeliverNoEffect
    () {
        
        assert(.loaded, on: .init(status: .inflight), effect: nil)
    }

    func test_reduce_loaded_stateLoaded_shouldStateNotChanged() {
        
        assertState(.loaded, on: .init(status: .loaded))
    }
    
    func test_reduce_loaded_stateLoaded_shouldDeliverNoEffect
    () {
        
        assert(.loaded, on: .init(status: .loaded), effect: nil)
    }
    
    func test_reduce_failure_error_stateInflight_shouldStateToFailure() {
        
        assertState(.failure(.error), on: .init(status: .failure))
    }
    
    func test_reduce_failure_error_stateInflight_shouldDeliverShowAlertEffect
    () {
        
        assert(.failure(.error), on: .init(status: .inflight), effect: .show(.alert(.never)))
    }

    func test_reduce_failure_timeout_stateInflight_shouldStateToFailure() {
        
        assertState(.failure(.timeout), on: .init(status: .failure))
    }
    
    func test_reduce_failure_timeout_stateInflight_shouldDeliverShowInformerEffect
    () {
        
        assert(.failure(.timeout), on: .init(status: .inflight), effect: .show(.informer))
    }

    // MARK: - Helpers
    
    private typealias SUT = MarketShowcaseReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        alertLifespan: DispatchTimeInterval = .never,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(alertLifespan: alertLifespan)
        
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
    }*/
}
