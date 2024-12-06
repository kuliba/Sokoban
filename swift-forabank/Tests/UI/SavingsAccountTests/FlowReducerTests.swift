//
//  FlowReducerTests.swift
//
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import XCTest
import Combine
import SavingsAccount

final class FlowReducerTests: XCTestCase {
    
    func test_reduce_destination_shouldStatusToDestination() {
        
        let destination = anyMessage()
        
        assertState(.destination(destination), on: .init()) {
            
            $0.status = .destination(destination)
        }
    }
    
    func test_reduce_destination_shouldDeliverNoEffect() {
        
        assert(.destination(anyMessage()), on: .init(), effect: nil)
    }
    
    func test_reduce_failure_timeout_shouldStatusToInformer() {
        
        let timeout = anyMessage()
        
        assertState(.failure(.timeout(timeout)), on: .init()) {
            
            $0.status = .informer(timeout)
        }
    }
    
    func test_reduce_failure_timeout_shouldDeliverNoEffect() {
        
        assert(.failure(.timeout(anyMessage())), on: .init(), effect: nil)
    }
    
    func test_reduce_failure_error_shouldStateToAlert() {
        
        let error = anyMessage()
        
        assertState(.failure(.error(error)), on: .init()) {
            
            $0.status = .alert(.init(message: error))
        }
    }
    
    func test_reduce_failure_error_shouldDeliverNoEffect() {
        
        assert(.failure(.error(anyMessage())), on: .init(), effect: nil)
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
    
    func test_reduce_select_order_shouldStateToOutsideOrder() {
        
        assertState(.select(.order), on: .init()) {
            
            $0.status = .outside(.order)
        }
    }
    
    func test_reduce_select_order_shouldDeliverNoEffect() {
        
        assert(.select(.order), on: .init(), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FlowReducer<String, String>
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
    
    private typealias UpdateStateToExpected = (_ state: inout State) -> Void
    
    private func assertState(
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected? = nil,
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
