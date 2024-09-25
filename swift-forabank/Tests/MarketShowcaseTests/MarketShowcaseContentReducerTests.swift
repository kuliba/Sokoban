//
//  MarketShowcaseContentReducerTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import XCTest
import RxViewModel
import Combine
import MarketShowcase

final class MarketShowcaseContentReducerTests: XCTestCase {
    
    func test_reduce_load_stateInflight_shouldStateNotChanged() {
        
        assertState(.load, on: .init(status: .inflight))
    }
    
    func test_reduce_load_stateInflight_shouldDeliverLoadEffect
    () {
        
        assert(.load, on: .init(status: .inflight), effect: nil)
    }
    
    func test_reduce_load_stateLoaded_shouldStatusToInflight() {
        
        assertState(.load, on: .init(status: .loaded(""))) {
            $0.status = .inflight
        }
    }
    
    func test_reduce_load_stateLoaded_shouldDeliverLoadEffect
    () {
        
        assert(.load, on: .init(status: .loaded("")), effect: .load)
    }
    
    func test_reduce_loaded_stateInflight_shouldStatusToLoaded() {
        
        assertState(.loaded("landing"), on: .init(status: .inflight)) {
            $0.status = .loaded("landing")
        }
    }
    
    func test_reduce_loaded_stateInflight_shouldDeliverNoEffect
    () {
        
        assert(.loaded(""), on: .init(status: .inflight), effect: nil)
    }

    func test_reduce_loaded_stateLoaded_shouldStatusToNewLoaded() {
        
        assertState(.loaded("new"), on: .init(status: .loaded("old"))) {
            $0.status = .loaded("new")
        }
    }
    
    func test_reduce_loaded_stateLoaded_shouldDeliverNoEffect
    () {
        
        assert(.loaded("old"), on: .init(status: .loaded("new")), effect: nil)
    }
    
    func test_reduce_loadFailure_stateInflight_shouldStatusToFailure() {
        
        assertState(.loadFailure, on: .init(status: .failure)) {
            $0.status = .failure
        }
    }
    
    func test_reduce_loadFailure_stateInflight_shouldDeliverNoEffect() {
        
        assert(.loadFailure, on: .init(status: .failure), effect: nil)
    }
    
    func test_reduce_selectLandingType_shouldSelectionToLanding() {
        
        assertState(.selectLandingType("landing"), on: .init(status: .inflight)) {
            $0.selection = .landingType("landing")
        }
    }
    
    func test_reduce_selectLandingType_shouldDeliverNoEffect() {
        
        assert(.selectLandingType("landing"), on: .init(status: .inflight), effect: nil)
    }

    func test_reduce_reset_shouldSelectionToNil() {
        
        assertState(.resetSelection, on: .init(selection: .landingType(""), status: .inflight)) {
            $0.selection = nil
        }
    }
    
    func test_reduce_reset_shouldDeliverNoEffect() {
        
        assert(.loadFailure, on: .init(selection: .landingType(""), status: .inflight), effect: nil)
    }


    // MARK: - Helpers
    
    private typealias SUT = MarketShowcaseContentReducer<String>
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
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
