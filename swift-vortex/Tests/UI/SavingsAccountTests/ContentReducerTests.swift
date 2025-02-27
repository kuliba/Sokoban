//
//  ContentReducerTests.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import XCTest
import SavingsAccount

final class ContentReducerTests: XCTestCase {
    
    func test_reduce_load_stateInflight_shouldNotChangeStated() {
        
        assertState(.load, on: .init(state: .inflight(nil)))
    }
    
    func test_reduce_load_stateInflight_shouldDeliverLoadEffect
    () {
        
        assert(.load, on: .init(state: .inflight(nil)), effect: nil)
    }
        
    func test_reduce_load_stateLoaded_shouldStateToInflight() {
        
        let landing = anyMessage()
        
        assertState(.load, on: .init(state: .loaded(landing))) {
            
            $0.state = .inflight(landing)
        }
    }
    
    func test_reduce_load_stateLoaded_shouldDeliverLoadEffect() {
      
        assert(.load, on: .init(state: .loaded(anyMessage())), effect: .load)
    }
    
    func test_reduce_result_success_stateInflight_shouldStateToLoaded() {
        
        let landing = anyMessage()

        assertState(.result(.success(landing)), on: .init(state: .inflight(nil))) {
            
            $0.state = .loaded(landing)
        }
    }
    
    func test_reduce_result_success_stateInflight_shouldDeliverNoEffect() {
        
        assert(.result(.success(anyMessage())), on: .init(state: .inflight(nil)), effect: nil)
    }

    func test_reduce_result_success_stateLoaded_shouldstateToNewLoaded() {
        
        assertState(.result(.success("new")), on: .init(state: .loaded("old"))) {
            
            $0.state = .loaded("new")
        }
    }
    
    func test_reduce_result_success_stateLoaded_shouldDeliverNoEffect() {
        
        assert(.result(.success("old")), on: .init(state: .loaded("new")), effect: nil)
    }
    
    func test_reduce_result_failureAlert_stateInflight_shouldstateToFailure() {
        
        let alert = anyMessage()
        let landing = anyMessage()
        
        assertState(.result(.failure(.init(kind: .alert(alert)))), on: .init(state: .inflight(landing))) {
            
            $0.state = .failure(.alert(alert), landing)
        }
    }
    
    func test_reduce_result_failureAlert_stateInflight_shouldDeliverNoEffect() {
        
        assert(.result(.failure(.init(kind: .alert(anyMessage())))), on: .init(state: .inflight(nil)), effect: nil)
    }
    
    func test_reduce_result_failureInformer_stateInflight_shouldstateToFailure() {
        
        let informer = anyMessage()
        let landing = anyMessage()
        
        assertState(.result(.failure(.init(kind: .informer(informer)))), on: .init(state: .inflight(landing))) {
            
            $0.state = .failure(.informer(informer), landing)
        }
    }
    
    func test_reduce_result_failureInformer_stateInflight_shouldDeliverNoEffect() {
        
        assert(.result(.failure(.init(kind: .alert(anyMessage())))), on: .init(state: .inflight(nil)), effect: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = ContentReducer<String, String>
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias UpdateStateToExpected = (_ state: inout State) -> Void
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
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
