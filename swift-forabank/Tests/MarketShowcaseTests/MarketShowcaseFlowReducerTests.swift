//
//  MarketShowcaseFlowReducerTests.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import XCTest
import RxViewModel
import Combine
import MarketShowcase

final class MarketShowcaseFlowReducerTests: XCTestCase {
    
    func test_reduce_destination_shouldStatusToDestination() {
        
        assertState(.destination("destination"), on: .init()) {
            
            $0.status = .destination("destination")
        }
    }
    
    func test_reduce_destination_shouldDeliverNoEffect() {
        
        assert(.destination("destination"), on: .init(), effect: nil)
    }
    
    func test_reduce_failure_timeout_shouldStatusToInformer() {
        
        assertState(.failure(.timeout("timeout")), on: .init()) {
            
            $0.status = .informer("timeout")
        }
    }
    
    func test_reduce_failure_timeout_shouldDeliverNoEffect() {
        
        assert(.failure(.timeout("timeout")), on: .init(), effect: nil)
    }
    
    func test_reduce_failure_error_shouldStateToAlert() {
        
        assertState(.failure(.error("error")), on: .init()) {
            
            $0.status = .alert(.init(message: "error"))
        }
    }
    
    func test_reduce_failure_error_shouldDeliverNoEffect() {
        
        assert(.failure(.error("error")), on: .init(), effect: nil)
    }

    func test_reduce_reset_shouldStateToNil() {
        
        assertState(.reset, on: .init(status:  .destination(""))) {
            
            $0.status = nil
        }
    }
    
    func test_reduce_reset_shouldDeliverNoEffect() {
        
        assert(.reset, on: .init(status:  .destination("")), effect: nil)
    }
    
    func test_reduce_select_goToMain_shouldStateToOutsideMain() {
        
        assertState(.select(.goToMain), on: .init()) {
            
            $0.status = .outside(.main)
        }
    }
    
    func test_reduce_select_goToMain_shouldDeliverNoEffect() {
        
        assert(.select(.goToMain), on: .init(), effect: nil)
    }

    func test_reduce_select_orderCard_shouldNotChangeState() {
        
        assertState(.select(.orderCard), on: .init())
    }
    
    func test_reduce_select_orderCard_shouldDeliverOrderCardEffect() {
        
        assert(.select(.orderCard), on: .init(), effect: .select(.orderCard))
    }
    
    func test_reduce_select_orderSticker_shouldNotChangeState() {
        
        assertState(.select(.orderSticker), on: .init())
    }
    
    func test_reduce_select_orderSticker_shouldDeliverOrderStickerEffect() {
        
        assert(.select(.orderSticker), on: .init(), effect: .select(.orderSticker))
    }

    // MARK: - Helpers
    
    private typealias SUT = MarketShowcaseFlowReducer<String, String>
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
