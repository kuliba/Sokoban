//
//  AnywayPaymentContextReducerTests.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentContextReducerTests: XCTestCase {
    
    func test_reduce_shouldUpdatePayment() {
        
        let state = makeAnywayPaymentContext(
            payment: makeAnywayPayment(
                elements: [makeAnywayPaymentParameterElement()]
            )
        )
        let paymentWithSuccess = makeAnywayPayment(
            elements: [makeAnywayPaymentParameterElement()]
        )
        let event = Event.setValue(anyMessage(), for: anyMessage())
        let sut = makeSUT(reduce: { _,_ in (paymentWithSuccess, nil) })
        
        assertState(sut: sut, event, on: state) {
            
            $0.payment = paymentWithSuccess
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentContextReducer
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        reduce: @escaping SUT.AnywayPaymentReduce = { state,_ in (state, nil) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(anywayPaymentReduce: reduce)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
