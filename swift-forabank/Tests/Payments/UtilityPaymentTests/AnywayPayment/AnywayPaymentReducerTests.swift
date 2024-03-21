//
//  AnywayPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

import UtilityPayment
import XCTest

final class AnywayPaymentReducerTests: XCTestCase {
    
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
    
    func test_fraudEvent_shouldNotDeliverEffectOnFraudCancelled() {
        
        assert(
            .fraud(.cancelled),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_fraudEvent_shouldChangePaymentToFraudCancelledOnFraudExpired() {
        
        assertState(
            .fraud(.expired),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.expired)))
        }
    }
    
    func test_fraudEvent_shouldNotDeliverEffectOnFraudExpired() {
        
        assert(
            .fraud(.expired),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_fraudEvent_shouldNotChangeSuccessResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_fraudEvent_shouldNotDeliverEffectOnSuccessResultState() {
        
        assert(
            .fraud(.cancelled),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_fraudEvent_shouldNotChangeTransferErrorResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_fraudEvent_shouldNotDeliverEffectOnTransferErrorResultState() {
        
        assert(
            .fraud(.cancelled),
            on: .result(.failure(.transferError)),
            effect: nil
        )
    }
    
    func test_fraudEvent_shouldNotChangeFraudCancelledResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_fraudEvent_shouldNotDeliverEffectOnFraudCancelledResultState() {
        
        assert(
            .fraud(.cancelled),
            on: .result(.failure(.fraud(.cancelled))),
            effect: nil
        )
    }
    
    func test_fraudEvent_shouldNotChangeFraudExpiredResultState() {
        
        assertState(
            .fraud(.cancelled),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
    func test_fraudEvent_shouldNotDeliverEffectOnFraudExpiredResultState() {
        
        assert(
            .fraud(.cancelled),
            on: .result(.failure(.fraud(.expired))),
            effect: nil
        )
    }
    
    // MARK: - receivedAnywayResult
    
    func test_receivedAnywayResult_shouldChangePaymentStateToConnectivityErrorResultOnConnectivityError() {
        
        assertState(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.transferError))
        }
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnPaymentStateOnConnectivityError() {
        
        assert(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldChangePaymentStateToServerErrorResultOnServerError() {
        
        let payment = makeUtilityPayment()
        let message = anyMessage()
        
        assertState(
            .receivedAnywayResult(.failure(.serverError(message))),
            on: .payment(payment)
        ) {
            $0 = .result(.failure(.serverError(message)))
        }
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnPaymentStateOnServerError() {
        
        assert(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldUpdatePaymentStateOnSuccessResponse() {
        
        let payment = makeUtilityPayment(
            isFinalStep: false,
            verificationCode: nil,
            status: .inflight
        )
        let response = makeCreateAnywayTransferResponse()
        let sut = makeSUT { payment, response in
            
            payment.isFinalStep = true
            payment.verificationCode = "987654"
        }
        
        assertState(
            sut: sut,
            .receivedAnywayResult(.success(response)),
            on: .payment(payment)
        ) {
            var payment = payment
            payment.status = .none
            payment.isFinalStep = true
            payment.verificationCode = "987654"
            $0 = .payment(payment)
        }
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnPaymentStateOnSuccessResponse() {
        
        assert(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeSuccessResultStateOnConnectivityError() {
        
        assertState(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedAnywayResult_shouldDeliverEffectOnSuccessResultStateOnConnectivityError() {
        
        assert(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeSuccessResultStateOnServerError() {
        
        assertState(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnSuccessResultStateOnServerError() {
        
        assert(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeSuccessResultStateOnSuccessResponse() {
        
        assertState(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnSuccessResultStateOnSuccessResponse() {
        
        assert(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeFraudCancelledFailureResultStateOnConnectivityError() {
        
        assertState(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnFraudCancelledFailureResultStateOnConnectivityError() {
        
        assert(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.failure(.fraud(.cancelled))),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeFraudCancelledFailureResultStateOnServerError() {
        
        assertState(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnFraudCancelledFailureResultStateOnServerError() {
        
        assert(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.failure(.fraud(.cancelled))),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeFraudCancelledFailureResultStateOnSuccessResponse() {
        
        assertState(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnFraudCancelledFailureResultStateOnSuccessResponse() {
        
        assert(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.failure(.fraud(.cancelled))),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeFraudExpiredFailureResultStateOnConnectivityError() {
        
        assertState(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnFraudExpiredFailureResultStateOnConnectivityError() {
        
        assert(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.failure(.fraud(.expired))),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeFraudExpiredFailureResultStateServerError() {
        
        assertState(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnFraudExpiredFailureResultStateServerError() {
        
        assert(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.failure(.fraud(.expired))),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeFraudExpiredFailureResultStateOnSuccessResponse() {
        
        assertState(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnFraudExpiredFailureResultStateOnSuccessResponse() {
        
        assert(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.failure(.fraud(.expired))),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeTransferErrorFailureResultStateOnConnectivityError() {
        
        assertState(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnTransferErrorFailureResultStateOnConnectivityError() {
        
        assert(
            .receivedAnywayResult(.failure(.connectivityError)),
            on: .result(.failure(.transferError)),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeTransferErrorFailureResultStateOnServerError() {
        
        assertState(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnTransferErrorFailureResultStateOnServerError() {
        
        assert(
            .receivedAnywayResult(.failure(.serverError(anyMessage()))),
            on: .result(.failure(.transferError)),
            effect: nil
        )
    }
    
    func test_receivedAnywayResult_shouldNotChangeTransferErrorFailureResultStateOnSuccessResponse() {
        
        assertState(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_receivedAnywayResult_shouldNotDeliverEffectOnTransferErrorFailureResultStateOnSuccessResponse() {
        
        assert(
            .receivedAnywayResult(.success(makeCreateAnywayTransferResponse())),
            on: .result(.failure(.transferError)),
            effect: nil
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
    
    func test_receivedTransferResult_shouldNotDeliverEffectAtPaymentStateOnSuccess() {
        
        assert(
            .receivedTransferResult(.success(makeTransaction())),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnFraudCancelledFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.cancelled)))
        }
    }
    
    func test_receivedTransferResult_shouldNotDeliverEffectAtPaymentStateOnFraudCancelledFailure() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnFraudExpiredFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.fraud(.expired)))
        }
    }
    
    func test_receivedTransferResult_shouldNotDeliverEffectAtPaymentStateOnFraudExpiredFailure() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldChangePaymentStateToResultOnTransferErrorFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .payment(makeUtilityPayment())
        ) {
            $0 = .result(.failure(.transferError))
        }
    }
    
    func test_receivedTransferResult_shouldNotDeliverEffectAtPaymentStateOnTransferErrorFailure() {
        
        assert(
            .receivedTransferResult(.failure(.transferError)),
            on: .payment(makeUtilityPayment()),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.success(makeTransaction())),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtSuccessResultStateOnSuccess() {
        
        assert(
            .receivedTransferResult(.success(makeTransaction())),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeTransferErrorFailureResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtTransferErrorFailureResultStateOnSuccess() {
        
        assert(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudCancelledFailureResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtFraudCancelledFailureResultStateOnSuccess() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudExpiredFailureResultStateOnSuccess() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtFraudExpiredFailureResultStateOnSuccess() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnTransferErrorFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtSuccessResultStateOnTransferErrorFailure() {
        
        assert(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeTransferErrorFailureResultStateOnTransferErrorFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.failure(.transferError))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtTransferErrorFailureResultStateOnTransferErrorFailure() {
        
        assert(
            .receivedTransferResult(.failure(.transferError)),
            on: .result(.failure(.transferError)),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnFraudCancelledFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtSuccessResultStateOnFraudCancelledFailure() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeSuccessResultStateOnFraudExpiredFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.success(makeTransaction()))
        )
    }
    
    func test_receivedTransferResult_shouldNotNotDeliverEffectAtSuccessResultStateOnFraudExpiredFailure() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.success(makeTransaction())),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudCancelledFailureResultStateOnFraudCancelledFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.failure(.fraud(.cancelled)))
        )
    }
    
    func test_receivedTransferResult_shouldNotDeliverEffectAtFraudCancelledFailureResultStateOnFraudCancelledFailure() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.cancelled))),
            on: .result(.failure(.fraud(.cancelled))),
            effect: nil
        )
    }
    
    func test_receivedTransferResult_shouldNotChangeFraudExpiredFailureResultStateOnFraudExpiredFailure() {
        
        assertState(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.failure(.fraud(.expired)))
        )
    }
    
    func test_receivedTransferResult_shouldNotDeliverEffectAtFraudExpiredFailureResultStateOnFraudExpiredFailure() {
        
        assert(
            .receivedTransferResult(.failure(.fraud(.expired))),
            on: .result(.failure(.fraud(.expired))),
            effect: nil
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentReducer<Payment, CreateAnywayTransferResponse>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        update: @escaping (inout Payment, CreateAnywayTransferResponse) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(update: update)
        
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
        let sut = sut ?? makeSUT(update: { _,_ in }, file: file, line: line)
        
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
        let sut = sut ?? makeSUT(update: { _,_ in }, file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
