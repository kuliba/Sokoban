//
//  UtilityPaymentReducerTests.swift
//  
//
//  Created by Igor Malyarov on 04.03.2024.
//

import UtilityPayment
import XCTest

final class UtilityPaymentReducerTests: XCTestCase {
    
    // MARK: - receivedTransferResult
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnSuccess() {
        
        let transaction = makeTransaction()
        
        assertState(
            .receivedTransferResult(.success(transaction)),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.success(transaction))
        }
    }
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnFraudCancelledFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.cancelled)))
        }
    }
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnFraudExpiredFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.expired)))
        }
    }
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnTransferErrorFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.transferError))
        }
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.success(makeTransaction())),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeTransferErrorFailureResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudCancelledFailureResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudExpiredFailureResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnTransferErrorFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeTransferErrorFailureResultStateOnTransferErrorFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnFraudCancelledFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnFraudExpiredFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudCancelledFailureResultStateOnFraudCancelledFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudExpiredFailureResultStateOnFraudExpiredFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentReducer
    
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
    
    private func makeUtilityPayment(
    ) -> UtilityPayment {
        
        .init()
    }
    
    private func makeTransaction(
        _ detailID: Int = generateRandom11DigitNumber(),
        documentStatus: Transaction.DocumentStatus = .complete
    ) -> Transaction {
        
        .init(
            paymentOperationDetailID: .init(detailID),
            documentStatus: documentStatus
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
        let sut = sut ?? makeSUT(file: file, line: line)

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
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
