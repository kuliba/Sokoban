//
//  MarketShowcaseContentReducerTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import XCTest
import RxViewModel
import Combine
import MarketShowcase

final class MarketShowcaseContentReducerTests: XCTestCase {
    
    func test_reduce_load_stateInflight_shouldNotChangeStated() {
        
        assertState(.load, on: .init(status: .inflight(nil)))
    }
    
    func test_reduce_load_stateInflight_shouldDeliverLoadEffect
    () {
        
        assert(.load, on: .init(status: .inflight(nil)), effect: nil)
    }
        
    func test_reduce_load_stateLoaded_shouldStatusToInflight() {
        
        let landing = anyMessage()
        
        assertState(.load, on: .init(status: .loaded(landing))) {
            
            $0.status = .inflight(landing)
        }
    }
    
    func test_reduce_load_stateLoaded_shouldDeliverLoadEffect() {
      
        let landing = anyMessage()

        assert(.load, on: .init(status: .loaded(landing)), effect: .load)
    }
    
    func test_reduce_loaded_stateInflight_shouldStatusToLoaded() {
        
        let landing = anyMessage()

        assertState(.loaded(landing), on: .init(status: .inflight(nil))) {
            $0.status = .loaded(landing)
        }
    }
    
    func test_reduce_loaded_stateInflight_shouldDeliverNoEffect() {
        
        assert(.loaded(""), on: .init(status: .inflight(nil)), effect: nil)
    }

    func test_reduce_loaded_stateLoaded_shouldStatusToNewLoaded() {
        
        assertState(.loaded("new"), on: .init(status: .loaded("old"))) {
            
            $0.status = .loaded("new")
        }
    }
    
    func test_reduce_loaded_stateLoaded_shouldDeliverNoEffect() {
        
        assert(.loaded("old"), on: .init(status: .loaded("new")), effect: nil)
    }
    
    func test_reduce_failureAlert_stateInflight_shouldStatusToFailure() {
        
        let alert = anyMessage()
        let landing = anyMessage()
        
        assertState(.failure(.alert(alert)), on: .init(status: .inflight(landing))) {
            
            $0.status = .failure(.alert(alert), landing)
        }
    }
    
    func test_reduce_failureAlert_stateInflight_shouldDeliverNoEffect() {
        
        let alert = anyMessage()

        assert(.failure(.alert(alert)), on: .init(status: .inflight(nil)), effect: nil)
    }
    
    func test_reduce_failureInformer_stateInflight_shouldStatusToFailure() {
        
        let informer = anyMessage()
        let landing = anyMessage()
        
        assertState(.failure(.informer(informer)), on: .init(status: .inflight(landing))) {
            
            $0.status = .failure(.informer(informer), landing)
        }
    }
    
    func test_reduce_failureInformer_stateInflight_shouldDeliverNoEffect() {
        
        let alert = anyMessage()

        assert(.failure(.alert(alert)), on: .init(status: .inflight(nil)), effect: nil)
    }

    
    func test_reduce_selectLandingType_shouldSelectionToLanding() {
        
        let landing = anyMessage()

        assertState(.selectLandingType(landing), on: .init(status: .inflight(nil))) {
            
            $0.selection = .landingType(landing)
        }
    }
    
    func test_reduce_selectLandingType_shouldDeliverNoEffect() {
        
        let landing = anyMessage()

        assert(.selectLandingType(landing), on: .init(status: .inflight(nil)), effect: nil)
    }

    func test_reduce_reset_shouldSelectionToNil() {
        
        assertState(.resetSelection, on: .init(selection: .landingType(""), status: .inflight(nil))) {
            
            $0.selection = nil
        }
    }
    
    func test_reduce_reset_shouldDeliverNoEffect() {
        
        assert(.resetSelection, on: .init(selection: .landingType(""), status: .inflight(nil)), effect: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = MarketShowcaseContentReducer<String, String>
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
