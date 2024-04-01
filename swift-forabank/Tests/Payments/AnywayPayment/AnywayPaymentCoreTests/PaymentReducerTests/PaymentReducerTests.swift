//
//  PaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentCore
import XCTest

final class PaymentReducerTests: XCTestCase {
    
    // MARK: - completePayment
    
    func test_completePayment_shouldNotChangeFraudSuspectedStatusStateOnReportFailure() {
        
        assertState(
            .completePayment(nil),
            on: makeFraudSuspectedPaymentState()
        )
    }
    
    func test_completePayment_shouldChangeStatusToTerminatedTransactionFailureOnReportFailure() {
        
        assertState(.completePayment(nil), on: makePaymentState()) {
            
            $0.status = .result(.failure(.transactionFailure))
        }
    }
    
    func test_completePayment_shouldNotChangeStateOnFraudSuspectedStatusOnDetailIDTransactionReport() {
        
        assertState(
            .completePayment(makeDetailIDTransactionReport()),
            on: makeFraudSuspectedPaymentState()
        )
    }
    
    func test_completePayment_shouldChangeStatusToProcessedDetailIDTransactionReport() {
        
        let report = makeDetailIDTransactionReport()
        
        assertState(.completePayment(report), on: makePaymentState()) {
            
            $0.status = .result(.success(report))
        }
    }
    
    func test_completePayment_shouldNotChangeStateOnFraudSuspectedStatusOnOperationDetailsTransactionReport() {
        
        assertState(
            .completePayment(makeOperationDetailsTransactionReport()),
            on: makeFraudSuspectedPaymentState()
        )
    }
    
    func test_completePayment_shouldChangeStatusToProcessedOperationDetailsTransactionReport() {
        
        let report = makeOperationDetailsTransactionReport()
        
        assertState(.completePayment(report), on: makePaymentState()) {
            
            $0.status = .result(.success(report))
        }
    }
    
    func test_completePayment_shouldNotDeliverEffectOnFraudSuspectedStatusOnReportFailure() {
        
        assert(
            .completePayment(nil),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnReportFailure() {
        
        assert(
            .completePayment(nil),
            on: makePaymentState(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnFraudSuspectedStatusOnDetailIDReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeDetailIDTransactionReport()),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnDetailIDReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeDetailIDTransactionReport()),
            on: makePaymentState(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnFraudSuspectedStatusOnOperationDetailsReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeOperationDetailsTransactionReport()),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnOperationDetailsReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeOperationDetailsTransactionReport()),
            on: makePaymentState(),
            effect: nil
        )
    }
    
    // MARK: - continue
    
    func test_continue_shouldNotChangeStateOnInvalidPayment() {
        
        assertState(.continue, on: makeInvalidPaymentState())
    }
    
    func test_continue_shouldNotDeliverEffectOnInvalidPayment() {
        
        assert(.continue, on: makeInvalidPaymentState(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnFraudSuspectedStatus() {
        
        assertState(.continue, on: makeFraudSuspectedPaymentState())
    }
    
    func test_continue_shouldNotDeliverEffectOnFraudSuspectedStatus() {
        
        assert(.continue, on: makeFraudSuspectedPaymentState(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnResultFailureStatus() {
        
        assertState(.continue, on: makeResultFailureState())
    }
    
    func test_continue_shouldNotDeliverEffectOnResultFailureStatus() {
        
        assert(.continue, on: makeResultFailureState(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnResultSuccessStatus() {
        
        assertState(.continue, on: makeResultSuccessState())
    }
    
    func test_continue_shouldNotDeliverEffectOnResultSuccessStatus() {
        
        assert(.continue, on: makeResultSuccessState(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnServerErrorStatus() {
        
        assertState(.continue, on: makeServerErrorState())
    }
    
    func test_continue_shouldNotDeliverEffectOnServerErrorStatus() {
        
        assert(.continue, on: makeServerErrorState(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnValidPaymentWithoutVerificationCode() {
        
        let sut = makeSUT(getVerificationCode: { _ in nil })
        
        assertState(sut: sut, .continue, on: makeValidPaymentState())
    }
    
    func test_continue_shouldDeliverContinueEffectOnValidPaymentWithoutVerificationCode() {
        
        let digest = makeDigest()
        let sut = makeSUT(
            getVerificationCode: { _ in nil },
            makeDigest: { _ in digest}
        )
        
        assert(
            sut: sut, .continue,
            on: makeValidPaymentState(),
            effect: .continue(digest)
        )
    }
    
    func test_continue_shouldCallMakeDigestWithPaymentOnValidPaymentWithoutVerificationCode() {
        
        let payment = makePayment()
        let makeDigestSpy = MakeDigestSpy(response: makeDigest())
        let sut = makeSUT(
            getVerificationCode: { _ in nil },
            makeDigest: makeDigestSpy.call
        )
        
        _ = sut.reduce(makeValidPaymentState(payment), .continue)
        
        XCTAssertNoDiff(makeDigestSpy.payloads, [payment])
    }
    
    func test_continue_shouldCallGetVerificationCodeWithPaymentOnValidPaymentWithoutVerificationCode() {
        
        let payment = makePayment()
        let getVerificationCodeSpy = GetVerificationCodeSpy(response: nil)
        let sut = makeSUT(getVerificationCode: getVerificationCodeSpy.call)
        
        _ = sut.reduce(makeValidPaymentState(payment), .continue)
        
        XCTAssertNoDiff(getVerificationCodeSpy.payloads, [payment])
    }
    
    func test_continue_shouldNotChangeStateOnValidPaymentWithVerificationCode() {
        
        let sut = makeSUT(getVerificationCode: { _ in makeVerificationCode() })
        
        assertState(sut: sut, .continue, on: makeValidPaymentState())
    }
    
    func test_continue_shouldDeliverMakePaymentEffectWithVerificationCodeOnValidPaymentWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let sut = makeSUT(getVerificationCode: { _ in verificationCode })
        
        assert(
            sut: sut, .continue,
            on: makeValidPaymentState(),
            effect: .makePayment(verificationCode)
        )
    }
    
    func test_continue_shouldNotCallMakeDigestWithPaymentOnValidPaymentWithVerificationCode() {
        
        let makeDigestSpy = MakeDigestSpy(response: makeDigest())
        let sut = makeSUT(
            getVerificationCode: { _ in makeVerificationCode() },
            makeDigest: makeDigestSpy.call
        )
        
        _ = sut.reduce(makeValidPaymentState(makePayment()), .continue)
        
        XCTAssertNoDiff(makeDigestSpy.payloads, [])
    }
    
    func test_continue_shouldCallGetVerificationCodeWithPaymentOnValidPaymentWithVerificationCode() {
        
        let payment = makePayment()
        let getVerificationCodeSpy = GetVerificationCodeSpy(response: makeVerificationCode())
        let sut = makeSUT(getVerificationCode: getVerificationCodeSpy.call)
        
        _ = sut.reduce(makeValidPaymentState(payment), .continue)
        
        XCTAssertNoDiff(getVerificationCodeSpy.payloads, [payment])
    }
    
    // MARK: - fraud
    
    func test_fraudCancel_shouldNotChangeNonFraudSuspectState() {
        
        assertState(
            makeFraudCancelEvent(),
            on: makeNonFraudSuspectedPaymentState()
        )
    }
    
    func test_fraudCancel_shouldNotDeliverEffectOnNonFraudSuspect() {
        
        assert(
            makeFraudCancelEvent(),
            on: makeNonFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_fraudCancel_shouldSetStatusToFraudTerminatedOnFraudSuspect() {
        
        assertState(makeFraudCancelEvent(), on: makeFraudSuspectedPaymentState()) {
            
            $0.status = .result(.failure(.fraud(.cancelled)))
        }
    }
    
    func test_fraudCancel_shouldNotDeliverEffectOnFraudSuspect() {
        
        assert(
            makeFraudCancelEvent(),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_fraudContinue_shouldNotChangeNonFraudSuspectState() {
        
        assertState(
            makeFraudContinueEvent(),
            on: makeNonFraudSuspectedPaymentState()
        )
    }
    
    func test_fraudContinue_shouldNotDeliverEffectOnNonFraudSuspect() {
        
        assert(
            makeFraudContinueEvent(),
            on: makeNonFraudSuspectedPaymentState(),
            effect: nil)
    }
    
    func test_fraudContinue_shouldResetStatusOnFraudSuspect() {
        
        assertState(makeFraudContinueEvent(), on: makeFraudSuspectedPaymentState()) {
            
            $0.status = nil
        }
    }
    
    func test_fraudContinue_shouldNotDeliverEffectOnFraudSuspect() {
        
        assert(
            makeFraudContinueEvent(),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_fraudExpired_shouldNotChangeNonFraudSuspectState() {
        
        assertState(
            makeFraudExpiredEvent(),
            on: makeNonFraudSuspectedPaymentState()
        )
    }
    
    func test_fraudExpired_shouldNotDeliverEffectOnNonFraudSuspect() {
        
        assert(
            makeFraudExpiredEvent(),
            on: makeNonFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_fraudExpired_shouldSetStatusToFraudTerminatedOnFraudSuspect() {
        
        assertState(makeFraudExpiredEvent(), on: makeFraudSuspectedPaymentState()) {
            
            $0.status = .result(.failure(.fraud(.expired)))
        }
    }
    
    func test_fraudExpired_shouldNotDeliverEffectOnFraudSuspect() {
        
        assert(
            makeFraudExpiredEvent(),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldNotChangeState() {
        
        assertState(.initiatePayment, on: makePaymentState())
    }
    
    func test_initiatePayment_shouldDeliverEffect() {
        
        let digest = makeDigest()
        let sut = makeSUT(makeDigest: { _ in digest })
        
        assert(sut: sut, .initiatePayment, on: makePaymentState(), effect: .initiatePayment(digest))
    }
    
    func test_initiatePayment_shouldNotChangeFraudSuspectedStatusState() {
        
        assertState(.initiatePayment, on: makeFraudSuspectedPaymentState())
    }
    
    func test_initiatePayment_shouldDeliverEffectOnFraudSuspectedStatusState() {
        
        assert(.initiatePayment, on: makeFraudSuspectedPaymentState(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeStateOnResultFailureStatus() {
        
        assertState(.initiatePayment, on: makeResultFailureState())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnResultFailureStatus() {
        
        assert(.initiatePayment, on: makeResultFailureState(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeStateOnResultSuccessStatus() {
        
        assertState(.initiatePayment, on: makeResultSuccessState())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnResultSuccessStatus() {
        
        assert(.initiatePayment, on: makeResultSuccessState(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeStateOnServerErrorStatus() {
        
        assertState(.initiatePayment, on: makeServerErrorState())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnServerErrorStatus() {
        
        assert(.initiatePayment, on: makeServerErrorState(), effect: nil)
    }

    // MARK: - parameter (or field or payment) event
    
    func test_parameter_shouldCallParameterReduceWithPaymentAndEvent() {
        
        let (payment, event) = (makePayment(), makeParameterEvent())
        let parameterReduceSpy = ParameterReduceSpy(response: (payment, nil))
        let sut = makeSUT(parameterReduce: parameterReduceSpy.call)
        
        _ = sut.reduce(makePaymentState(payment), .parameter(event))
        
        XCTAssertNoDiff(parameterReduceSpy.payloads.map(\.0), [payment])
        XCTAssertNoDiff(parameterReduceSpy.payloads.map(\.1), [event])
    }
    
    func test_parameter_shouldCallValidateWithUpdatedPayment() {
        
        let (payment, updated) = (makePayment(), makePayment())
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(
            parameterReduce: { _,_ in return (updated, nil) },
            validatePayment: validatePaymentSpy.call
        )
        
        _ = sut.reduce(makePaymentState(payment), .parameter(makeParameterEvent()))
        
        XCTAssertNoDiff(validatePaymentSpy.payloads, [updated])
        XCTAssertNotEqual(payment, updated)
    }
    
    func test_parameter_shouldNotChangeStateOnFraudSuspectedStatus() {
        
        let sut = makeSUT(parameterReduce: { _,_ in (makePayment(), nil) })
        
        assertState(
            sut: sut,
            makeParameterPaymentEvent(),
            on: makeFraudSuspectedPaymentState()
        )
    }
    
    func test_parameter_shouldSetPaymentToParameterReducePayment() {
        
        let newPayment = makePayment()
        let sut = makeSUT(parameterReduce: { _,_ in (newPayment, nil) })
        
        assertState(sut: sut, makeParameterPaymentEvent(), on: makePaymentState()) {
            
            $0.payment = newPayment
        }
    }
    
    func test_parameter_shouldNotDeliverEffectOnFraudSuspectedStatus() {
        
        let sut = makeSUT(parameterReduce: { _,_ in (makePayment(), makeParameterPaymentEffect()) })
        
        assert(
            sut: sut,
            makeParameterPaymentEvent(),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_parameter_shouldDeliverParameterReduceEffect() {
        
        let effect = makeParameterPaymentEffect()
        let sut = makeSUT(parameterReduce: { _,_ in (makePayment(), effect) })
        
        assert(
            sut: sut,
            makeParameterPaymentEvent(),
            on: makePaymentState(),
            effect: effect
        )
    }
    
    func test_parameter_shouldSetPaymentValidationToValidateResult_notValid() {
        
        let sut = makeSUT(validatePayment: { _ in false })
        
        let (state, _) = sut.reduce(makePaymentState(), .parameter(makeParameterEvent()))
        
        XCTAssertFalse(isValid(state))
    }
    
    func test_parameter_shouldSetPaymentValidationToValidateResult_valid() {
        
        let sut = makeSUT(validatePayment: { _ in true })
        
        let (state, _) = sut.reduce(makePaymentState(), .parameter(makeParameterEvent()))
        
        XCTAssertTrue(isValid(state))
    }
    
    // MARK: - update
    
    func test_update_shouldNotChangeStateOnFraudSuspectedStatusOnConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureEvent(), on: makeFraudSuspectedPaymentState())
    }
    
    func test_update_shouldChangeStatusToTerminatedUpdateFailureOnConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureEvent(), on: makePaymentState()) {
            
            $0.status = .result(.failure(.updateFailure))
        }
    }
    
    func test_update_shouldNotCallValidateOnConnectivityErrorFailure() {
        
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(validatePayment: validatePaymentSpy.call)
        
        _ = sut.reduce(makePaymentState(), makeUpdateFailureEvent())
        
        XCTAssert(validatePaymentSpy.payloads.isEmpty)
    }
    
    func test_update_shouldNotCallFraudCheckOnConnectivityErrorFailure() {
        
        let checkFraudSpy = CheckFraudSpy(response: false)
        let sut = makeSUT(checkFraud: checkFraudSpy.call)
        
        _ = sut.reduce(makePaymentState(), makeUpdateFailureEvent())
        
        XCTAssert(checkFraudSpy.payloads.isEmpty)
    }
    
    func test_update_shouldNotChangeStateOnFraudSuspectedStatusOnServerErrorFailure() {
        
        assertState(makeUpdateFailureEvent(anyMessage()), on: makeFraudSuspectedPaymentState())
    }
    
    func test_update_shouldChangeStatusToServerErrorOnServerErrorFailure() {
        
        let message = anyMessage()
        
        assertState(makeUpdateFailureEvent(message), on: makePaymentState()) {
            
            $0.status = .serverError(message)
        }
    }
    
    func test_update_shouldNotCallValidateOnServerErrorFailure() {
        
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(validatePayment: validatePaymentSpy.call(payload:))
        
        _ = sut.reduce(makePaymentState(), makeUpdateFailureEvent(anyMessage()))
        
        XCTAssert(validatePaymentSpy.payloads.isEmpty)
    }
    
    func test_update_shouldNotCallFraudCheckOnServerErrorFailure() {
        
        let checkFraudSpy = CheckFraudSpy(response: false)
        let sut = makeSUT(checkFraud: checkFraudSpy.call)
        
        _ = sut.reduce(makePaymentState(), makeUpdateFailureEvent(anyMessage()))
        
        XCTAssert(checkFraudSpy.payloads.isEmpty)
    }
    
    func test_update_shouldCallUpdateWithPaymentAndUpdate() {
        
        let (payment, update) = (makePayment(), makeUpdate())
        let updatePaymentSpy = UpdatePaymentSpy(response: makePayment())
        let sut = makeSUT(updatePayment: updatePaymentSpy.call)
        
        _ = sut.reduce(makePaymentState(payment), makeUpdateEvent(update))
        
        XCTAssertNoDiff(updatePaymentSpy.payloads.map(\.0), [payment])
        XCTAssertNoDiff(updatePaymentSpy.payloads.map(\.1), [update])
    }
    
    func test_update_shouldCallValidateWithUpdatedPayment() {
        
        let (payment, updated) = (makePayment(), makePayment())
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(
            updatePayment: { _, _ in updated },
            validatePayment: validatePaymentSpy.call
        )
        
        _ = sut.reduce(makePaymentState(payment), makeUpdateEvent())
        
        XCTAssertNoDiff(validatePaymentSpy.payloads, [updated])
        XCTAssertNotEqual(payment, updated)
    }
    
    func test_update_shouldCallFraudCheckWithUpdated() {
        
        let update = makeUpdate()
        let checkFraudSpy = CheckFraudSpy(response: false)
        let sut = makeSUT(checkFraud: checkFraudSpy.call)
        
        let (updated, _) = sut.reduce(makePaymentState(), makeUpdateEvent(update))
        
        XCTAssertNoDiff(checkFraudSpy.payloads, [updated.payment])
    }
    
    func test_update_shouldNotChangeStateOnFraudSuspectedStatus() {
        
        let sut = makeSUT(updatePayment: { _, _ in makePayment() })
        
        assertState(sut: sut, makeUpdateEvent(), on: makeFraudSuspectedPaymentState())
    }
    
    func test_update_shouldSetPaymentToUpdatedValue() {
        
        let (payment, updated) = (makePayment(), makePayment())
        let sut = makeSUT(updatePayment: { _, _ in updated })
        
        assertState(sut: sut, makeUpdateEvent(), on: makePaymentState(payment)) {
            
            $0.payment = updated
        }
        XCTAssertNotEqual(payment, updated)
    }
    
    func test_update_shouldSetPaymentValidationToValidateResult_notValid() {
        
        let sut = makeSUT(validatePayment: { _ in false })
        
        let (state, _) = sut.reduce(makePaymentState(), makeUpdateEvent())
        
        XCTAssertFalse(isValid(state))
    }
    
    func test_update_shouldSetPaymentValidationToValidateResult_valid() {
        
        let sut = makeSUT(validatePayment: { _ in true })
        
        let (state, _) = sut.reduce(makePaymentState(), makeUpdateEvent())
        
        XCTAssertTrue(isValid(state))
    }
    
    func test_update_shouldSetFraudToCheckFraudResult_notSuspected() {
        
        let sut = makeSUT(checkFraud: { _ in false })
        
        let (state, _) = sut.reduce(makePaymentState(), makeUpdateEvent())
        
        XCTAssertFalse(isFraudSuspected(state))
    }
    
    func test_update_shouldSetFraudToCheckFraudResult_suspected() {
        
        let sut = makeSUT(checkFraud: { _ in true })
        
        let (state, _) = sut.reduce(makePaymentState(), makeUpdateEvent())
        
        XCTAssertTrue(isFraudSuspected(state))
    }
    
    func test_update_shouldNotDeliverEffectOnFraudSuspectedStatusOnConnectivityErrorFailure() {
        
        assert(
            makeUpdateFailureEvent(),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        assert(
            makeUpdateFailureEvent(),
            on: makePaymentState(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnFraudSuspectedStatusOnServerErrorFailure() {
        
        assert(
            makeUpdateFailureEvent(anyMessage()),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnServerErrorFailure() {
        
        assert(
            makeUpdateFailureEvent(anyMessage()),
            on: makePaymentState(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnFraudSuspectedStatus() {
        
        assert(
            makeUpdateEvent(),
            on: makeFraudSuspectedPaymentState(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnUpdate() {
        
        assert(
            makeUpdateEvent(),
            on: makePaymentState(),
            effect: nil
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentReducer<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Payment, Update>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias CheckFraudSpy = CallSpy<Payment, Bool>
    private typealias MakeDigestSpy = CallSpy<Payment, Digest>
    private typealias GetVerificationCodeSpy = CallSpy<Payment, VerificationCode?>
    private typealias ParameterReduceSpy = CallSpy<(Payment, ParameterEvent), (Payment, SUT.Effect?)>
    private typealias UpdatePaymentSpy = CallSpy<(Payment, Update), Payment>
    private typealias ValidatePaymentSpy = CallSpy<Payment, Bool>
    
    private func makeSUT(
        checkFraud: @escaping SUT.CheckFraud = { _ in false },
        getVerificationCode: @escaping SUT.GetVerificationCode = { _ in nil },
        makeDigest: @escaping SUT.MakeDigest = { _ in makeDigest() },
        parameterReduce: @escaping SUT.ParameterReduce = { payment, _ in (payment, nil) },
        updatePayment: @escaping SUT.UpdatePayment = { payment, _ in payment },
        validatePayment: @escaping SUT.ValidatePayment = { _ in false },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            checkFraud: checkFraud,
            getVerificationCode: getVerificationCode,
            makeDigest: makeDigest,
            parameterReduce: parameterReduce,
            updatePayment: updatePayment,
            validatePayment: validatePayment
        )
        
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
