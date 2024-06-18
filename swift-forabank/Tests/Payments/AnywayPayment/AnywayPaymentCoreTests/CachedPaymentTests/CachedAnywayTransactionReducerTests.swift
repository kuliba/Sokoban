//
//  CachedAnywayTransactionReducerTests.swift
//  
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentCore
import XCTest

final class CachedAnywayTransactionReducerTests: XCTestCase {
    
    // MARK: - stateUpdate
    
    func test_stateUpdate_shouldUpdateState() {
        
        assertState(.stateUpdate(makeInput(1)), on: makeState("a")) {
            
            $0 = self.makeState("a1")
        }
    }
    
    func test_stateUpdate_shouldNotDeliverEffect() {
        
        assert(.stateUpdate(makeInput()), on: makeState(), effect: nil)
    }
    
    // MARK: - transaction
    
    func test_transaction_shouldNotChangeState() {
        
        assertState(.transaction(.continue), on: makeState())
    }
    
    func test_transaction_shouldDeliverEffect() {
        
        assert(.transaction(.continue), on: makeState(), effect: .event(.continue))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CachedAnywayTransactionReducer<Input, State, TransactionEvent>
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(update: { .init(value: $0.value + "\($1.value)") })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeInput(
        _ value: Int = .random(in: 1...1_000)
    ) -> Input {
        
        return .init(value: value)
    }
    
    private func makeState(
        _ value: String = anyMessage()
    ) -> State {
        
        return .init(value: value)
    }
    
    private struct Input: Equatable {
        
        let value: Int
    }
    
    private struct State: Equatable {
        
        let value: String
    }
    
    private enum TransactionEvent: Equatable {
        
        case `continue`
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
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
