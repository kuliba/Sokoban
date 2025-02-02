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
      
        assert(.load, on: .init(status: .loaded(anyMessage())), effect: .load)
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
        
        assert(.failure(.alert(anyMessage())), on: .init(status: .inflight(nil)), effect: nil)
    }
    
    func test_reduce_failureInformer_stateInflight_shouldStatusToFailure() {
        
        let informer = anyMessage()
        let landing = anyMessage()
        
        assertState(.failure(.informer(informer)), on: .init(status: .inflight(landing))) {
            
            $0.status = .failure(.informer(informer), landing)
        }
    }
    
    func test_reduce_failureInformer_stateInflight_shouldDeliverNoEffect() {
        
        assert(.failure(.alert(anyMessage())), on: .init(status: .inflight(nil)), effect: nil)
    }
    
    func test_reduce_offsetMoreThenShowTitleOffset_shouldNavTitleToValue() {
        
        let landing = anyMessage()
        let sut = makeSUT(showTitleRange: 20...)
        
        assertState(sut: sut, .offset(25), on: .init(status: .loaded(landing))) {
            
            $0.navTitle = .savingsAccount
        }
    }
    
    func test_reduce_offsetMoreThenShowTitleOffset_shouldDeliverNoEffect() {
        
        let landing = anyMessage()
        let sut = makeSUT(showTitleRange: 20...)

        assert(sut: sut, .offset(25), on: .init(status: .loaded(landing)), effect: nil)
    }
    
    func test_reduce_offsetLessThenShowTitleOffset_shouldNotChangeState() {
        
        let landing = anyMessage()
        let sut = makeSUT(showTitleRange: 20...)
        
        assertState(sut: sut, .offset(18), on: .init(status: .loaded(landing)))
    }
    
    func test_reduce_offsetLessThenShowTitleOffset_shouldDeliverNoEffect() {
        
        let landing = anyMessage()
        let sut = makeSUT(showTitleRange: 20...)

        assert(sut: sut, .offset(18), on: .init(status: .loaded(landing)), effect: nil)
    }

    func test_reduce_refreshOffsetContainOffset_shouldStatusToInflight() {
        
        let landing = anyMessage()
        let sut = makeSUT(refreshRange: 0..<10)
        
        assertState(sut: sut, .offset(8), on: .init(status: .loaded(landing))) {
            
            $0.status = .inflight(landing)
        }
    }
    
    func test_reduce_refreshOffsetContainOffset_shouldDeliverLoadEffect() {
        
        let landing = anyMessage()
        let sut = makeSUT(refreshRange: 0..<10)

        assert(sut: sut, .offset(8), on: .init(status: .loaded(landing)), effect: .load)
    }
    
    func test_reduce_refreshOffsetNotContainOffset_shouldNotChangeState() {
        
        let landing = anyMessage()
        let sut = makeSUT(refreshRange: 0..<10)
        
        assertState(sut: sut, .offset(18), on: .init(status: .loaded(landing)))
    }
    
    func test_reduce_refreshOffsetNotContainOffset_shouldDeliverNoEffect() {
        
        let landing = anyMessage()
        let sut = makeSUT(refreshRange: 0..<10)

        assert(sut: sut, .offset(18), on: .init(status: .loaded(landing)), effect: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = ContentReducer<String, String>
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias UpdateStateToExpected = (_ state: inout State) -> Void
    
    private func makeSUT(
        refreshRange: Range<CGFloat> = -102..<0,
        showTitleRange: PartialRangeFrom<CGFloat> = 100...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(refreshRange: refreshRange, showTitleRange: showTitleRange)
        
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
