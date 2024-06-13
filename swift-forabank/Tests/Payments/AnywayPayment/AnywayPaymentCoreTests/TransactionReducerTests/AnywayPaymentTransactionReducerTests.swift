//
//  AnywayPaymentTransactionReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentTransactionReducerTests: XCTestCase {
    
    func test_init() {
        
        _ = makeSUT()
    }
    
    func test_dismissRecoverableError_shouldNotChangeTerminatedState() {
        
        let state = makeState(
            status: .result(.failure(.updatePaymentFailure))
        )
        
        assertState(.dismissRecoverableError, on: state)
    }
    
    func test_dismissRecoverableError_shouldResetServerErrorStatus() {
        
        let state = makeState(
            status: .serverError(anyMessage())
        )
        
        assertState(.dismissRecoverableError, on: state) {
            
            $0.status = nil
        }
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffect() {
        
        let state = makeState(
            status: .result(.failure(.updatePaymentFailure))
        )
        
        assert(.dismissRecoverableError, on: state, effect: nil)
    }
    
    // TODO: add integration tests
    
    // MARK: - Helpers
    
    private typealias SUT = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias Report = String
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let composer = AnywayPaymentTransactionReducerComposer<Report>()
        let sut = composer.compose()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        context: AnywayPaymentContext? = nil,
        isValid: Bool = true,
        status: TransactionStatus<Report>? = nil
    ) -> State {
        
        return .init(
            context: context ?? makeAnywayPaymentContext(),
            isValid: isValid,
            status: status
        )
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
