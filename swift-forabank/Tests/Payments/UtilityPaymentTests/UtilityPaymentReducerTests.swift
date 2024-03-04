//
//  UtilityPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

import UtilityPayment
import XCTest

final class UtilityPaymentReducerTests: XCTestCase {
    
    // MARK: - continue
    
    func test_continue_shouldChangeStatusToInflightOnNonFinalStepPaymentState() {
        
        let nonFinalStepPayment = makeNonFinalStepUtilityPayment()
        
        assertState(.continue, on: .payment(nonFinalStepPayment)) {
            
            var inflight = nonFinalStepPayment
            inflight.status = .inflight
            $0 = .payment(inflight)
        }
        
        XCTAssertFalse(nonFinalStepPayment.isFinalStep)
    }
    
    func test_continue_shouldDeliverCreateAnywayTransferEffectOnNonFinalStep() {
        
        let nonFinalStepPayment = makeNonFinalStepUtilityPayment()
        
        var inflight = nonFinalStepPayment
        inflight.status = .inflight
        
        assert(
            .continue,
            on: .payment(nonFinalStepPayment),
            effect: .createAnywayTransfer(inflight)
        )
    }
    
    func test_continue_shouldNotChangeStateOnFinalStepPaymentStateWithoutVerificationCode() {
        
        let finalStepPayment = makeFinalStepUtilityPayment(
            verificationCode: nil
        )
        
        assertState(.continue, on: .payment(finalStepPayment))
        
        XCTAssert(finalStepPayment.isFinalStep)
        XCTAssertNil(finalStepPayment.verificationCode)
    }
    
    func test_continue_shouldNotDeliverEffectOnFinalStepPaymentStateWithoutVerificationCode() {
        
        let finalStepPayment = makeFinalStepUtilityPayment(
            verificationCode: nil
        )
        
        assert(.continue, on: .payment(finalStepPayment), effect: nil)
        
        XCTAssert(finalStepPayment.isFinalStep)
        XCTAssertNil(finalStepPayment.verificationCode)
    }
    
    func test_continue_shouldChangeStatusToInflightOnFinalStepPaymentStateWithVerificationCode() {
        
        let finalStepPayment = makeFinalStepUtilityPayment(
            verificationCode: "12345"
        )
        
        assertState(.continue, on: .payment(finalStepPayment)) {
            
            var inflight = finalStepPayment
            inflight.status = .inflight
            $0 = .payment(inflight)
        }
        
        XCTAssert(finalStepPayment.isFinalStep)
        XCTAssertNotNil(finalStepPayment.verificationCode)
    }
    
    func test_continue_shouldDeliverMakeTransferEffectOnFinalStepWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let finalStepPayment = makeFinalStepUtilityPayment(
            verificationCode: verificationCode
        )
        
        assert(
            .continue,
            on: .payment(finalStepPayment),
            effect: .makeTransfer(verificationCode)
        )
        
        XCTAssert(finalStepPayment.isFinalStep)
        XCTAssertNotNil(finalStepPayment.verificationCode)
    }
    
    func test_continue_shouldNotChangeSuccessResultState() {
        
        assertState(.continue, on: .result(.success(makeTransaction())))
    }
    
    func test_continue_shouldNotDeliverEffectOnSuccessResultState() {
        
        assert(.continue, on: .result(.success(makeTransaction())), effect: nil)
    }
    
    func test_continue_shouldNotChangeFraudCancelledResultState() {
        
        assertState(.continue, on: .result(.failure(.fraud(.cancelled))))
    }
    
    func test_continue_shouldNotDeliverEffectOnFraudCancelledResultState() {
        
        assert(.continue, on: .result(.failure(.fraud(.cancelled))), effect: nil)
    }
    
    func test_continue_shouldNotChangeFraudExpiredResultState() {
        
        assertState(.continue, on: .result(.failure(.fraud(.expired))))
    }
    
    func test_continue_shouldNotDeliverEffectOnFraudExpiredResultState() {
        
        assert(.continue, on: .result(.failure(.fraud(.expired))), effect: nil)
    }
    
    func test_continue_shouldNotChangeTransferErrorResultState() {
        
        assertState(.continue, on: .result(.failure(.transferError)))
    }
    
    func test_continue_shouldNotDeliverEffectOnTransferErrorResultState() {
        
        assert(.continue, on: .result(.failure(.transferError)), effect: nil)
    }
    
    // MARK: - fraudEvent
    
    func test_fraudEvent_shouldChangePaymentToFraudCancelledOnFraudCancelled() {
        
        assertState(
            .fraud(.cancelled),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.cancelled)))
        }
    }
    
    func test_fraudEvent_shouldChangePaymentToFraudCancelledOnFraudExpired() {
        
        assertState(
            .fraud(.expired),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.expired)))
        }
    }
    
    func test_fraudEvent_shouldNotChangeSuccessResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_fraudEvent_shouldNotChangeTransferErrorResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_fraudEvent_shouldNotChangeFraudCancelledResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_fraudEvent_shouldNotChangeFraudExpiredResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
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
    
    private func makeFinalStepUtilityPayment(
        verificationCode: VerificationCode? = "654321"
    ) -> UtilityPayment {
        
        .init(
            isFinalStep: true,
            verificationCode: verificationCode
        )
    }
    
    private func makeNonFinalStepUtilityPayment(
    ) -> UtilityPayment {
        
        .init(isFinalStep: false)
    }
    
    func makeVerificationCode(
        _ value: String = UUID().uuidString
    ) -> VerificationCode {
        
        .init(value)
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
