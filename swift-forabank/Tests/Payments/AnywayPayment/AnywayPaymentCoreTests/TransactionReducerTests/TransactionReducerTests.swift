//
//  TransactionReducerTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentDomain
import AnywayPaymentCore
import XCTest

final class TransactionReducerTests: XCTestCase {
    
    // MARK: - completePayment
    
    func test_completePayment_shouldNotChangeResultFailureStateOnReportFailure() {
        
        assertState(.completePayment(nil), on: makeResultFailureTransaction())
    }
    
    func test_completePayment_shouldNotDeliverEffectOnResultFailureStateOnReportFailure() {
        
        assert(.completePayment(nil), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_completePayment_shouldNotChangeResultSuccessStateOnReportFailure() {
        
        assertState(.completePayment(nil), on: makeResultSuccessTransaction())
    }
    
    func test_completePayment_shouldNotDeliverEffectOnResultSuccessStateOnReportFailure() {
        
        assert(.completePayment(nil), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_completePayment_shouldNotChangeFraudSuspectedStatusStateOnReportFailure() {
        
        let context = makeContext()
        
        assertState(
            .completePayment(nil),
            on: makeFraudSuspectedTransaction(context)
        )
    }
    
    func test_completePayment_shouldChangeStatusToTerminatedTransactionFailureOnReportFailure() {
        
        assertState(.completePayment(nil), on: makeTransaction()) {
            
            $0.status = .result(.failure(.transactionFailure))
        }
    }
    
    func test_completePayment_shouldNotChangeResultFailureStateOnDetailIDTransactionReport() {
        
        assertState(
            .completePayment(makeDetailIDTransactionReport()),
            on: makeResultFailureTransaction()
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnResultFailureStateOnDetailIDTransactionReport() {
        
        assert(
            .completePayment(makeDetailIDTransactionReport()),
            on: makeResultFailureTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotChangeResultSuccessStateOnDetailIDTransactionReport() {
        
        assertState(
            .completePayment(makeDetailIDTransactionReport()),
            on: makeResultSuccessTransaction()
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnResultSuccessStateOnDetailIDTransactionReport() {
        
        assert(
            .completePayment(makeDetailIDTransactionReport()),
            on: makeResultSuccessTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotChangeStateOnFraudSuspectedStatusOnDetailIDTransactionReport() {
        
        assertState(
            .completePayment(makeDetailIDTransactionReport()),
            on: makeFraudSuspectedTransaction()
        )
    }
    
    func test_completePayment_shouldChangeStatusToProcessedDetailIDTransactionReport() {
        
        let report = makeDetailIDTransactionReport()
        
        assertState(.completePayment(report), on: makeTransaction()) {
            
            $0.status = .result(.success(report))
        }
    }
    
    func test_completePayment_shouldNotChangeResultFailureStateOnOperationDetailsTransactionReport() {
        
        assertState(
            .completePayment(makeOperationDetailsTransactionReport()),
            on: makeResultFailureTransaction()
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnResultFailureStateOnOperationDetailsTransactionReport() {
        
        assert(
            .completePayment(makeOperationDetailsTransactionReport()),
            on: makeResultFailureTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotChangeResultSuccessStateOnOperationDetailsTransactionReport() {
        
        assertState(
            .completePayment(makeOperationDetailsTransactionReport()),
            on: makeResultSuccessTransaction()
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnResultSuccessStateOnOperationDetailsTransactionReport() {
        
        assert(
            .completePayment(makeOperationDetailsTransactionReport()),
            on: makeResultSuccessTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotChangeStateOnFraudSuspectedStatusOnOperationDetailsTransactionReport() {
        
        assertState(
            .completePayment(makeOperationDetailsTransactionReport()),
            on: makeFraudSuspectedTransaction()
        )
    }
    
    func test_completePayment_shouldChangeStatusToProcessedOperationDetailsTransactionReport() {
        
        let report = makeOperationDetailsTransactionReport()
        
        assertState(.completePayment(report), on: makeTransaction()) {
            
            $0.status = .result(.success(report))
        }
    }
    
    func test_completePayment_shouldNotDeliverEffectOnFraudSuspectedStatusOnReportFailure() {
        
        assert(
            .completePayment(nil),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnReportFailure() {
        
        assert(
            .completePayment(nil),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnFraudSuspectedStatusOnDetailIDReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeDetailIDTransactionReport()),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnDetailIDReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeDetailIDTransactionReport()),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnFraudSuspectedStatusOnOperationDetailsReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeOperationDetailsTransactionReport()),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_completePayment_shouldNotDeliverEffectOnOperationDetailsReport() {
        
        assert(
            makeCompletePaymentReportEvent(makeOperationDetailsTransactionReport()),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    // MARK: - continue
    
    func test_continue_shouldNotChangeStateOnInvalidPayment() {
        
        assertState(.continue, on: makeInvalidTransaction())
    }
    
    func test_continue_shouldNotDeliverEffectOnInvalidPayment() {
        
        assert(.continue, on: makeInvalidTransaction(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnFraudSuspectedStatus() {
        
        assertState(.continue, on: makeFraudSuspectedTransaction())
    }
    
    func test_continue_shouldNotDeliverEffectOnFraudSuspectedStatus() {
        
        assert(.continue, on: makeFraudSuspectedTransaction(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnResultFailureStatus() {
        
        assertState(.continue, on: makeResultFailureTransaction())
    }
    
    func test_continue_shouldNotDeliverEffectOnResultFailureStatus() {
        
        assert(.continue, on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnResultSuccessStatus() {
        
        assertState(.continue, on: makeResultSuccessTransaction())
    }
    
    func test_continue_shouldNotDeliverEffectOnResultSuccessStatus() {
        
        assert(.continue, on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_continue_shouldNotChangeStateOnServerErrorStatus() {
        
        assertState(.continue, on: makeServerErrorTransaction())
    }
    
    func test_continue_shouldNotDeliverEffectOnServerErrorStatus() {
        
        assert(.continue, on: makeServerErrorTransaction(), effect: nil)
    }
    
    func test_continue_shouldSetStatusToInflightOnValidPaymentWithoutVerificationCode() {
        
        let sut = makeSUT(getVerificationCode: { _ in nil })
        
        assertState(sut: sut, .continue, on: makeValidTransaction()) {
            
            $0.status = .inflight
        }
    }
    
    func test_continue_shouldDeliverContinueEffectOnValidPaymentWithoutVerificationCode() {
        
        let digest = makePaymentDigest()
        let sut = makeSUT(
            getVerificationCode: { _ in nil },
            makeDigest: { _ in digest }
        )
        
        assert(
            sut: sut, .continue,
            on: makeValidTransaction(),
            effect: .continue(digest)
        )
    }
    
    func test_continue_shouldCallMakeDigestWithPaymentOnValidPaymentWithoutVerificationCode() {
        
        let payment = makeContext()
        let makeDigestSpy = MakeDigestSpy(response: makePaymentDigest())
        let sut = makeSUT(
            getVerificationCode: { _ in nil },
            makeDigest: makeDigestSpy.call
        )
        
        _ = sut.reduce(makeValidTransaction(payment), .continue)
        
        XCTAssertNoDiff(makeDigestSpy.payloads, [payment])
    }
    
    func test_continue_shouldCallGetVerificationCodeWithPaymentOnValidPaymentWithoutVerificationCode() {
        
        let payment = makeContext()
        let getVerificationCodeSpy = GetVerificationCodeSpy(response: nil)
        let sut = makeSUT(getVerificationCode: getVerificationCodeSpy.call)
        
        _ = sut.reduce(makeValidTransaction(payment), .continue)
        
        XCTAssertNoDiff(getVerificationCodeSpy.payloads, [payment])
    }
    
    func test_continue_shouldSetStatusToInflightOnValidPaymentWithVerificationCode() {
        
        let sut = makeSUT(getVerificationCode: { _ in makeVerificationCode() })
        
        assertState(sut: sut, .continue, on: makeValidTransaction()) {
            
            $0.status = .inflight
        }
    }
    
    func test_continue_shouldDeliverMakePaymentEffectWithVerificationCodeOnValidPaymentWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let sut = makeSUT(getVerificationCode: { _ in verificationCode })
        
        assert(
            sut: sut, .continue,
            on: makeValidTransaction(),
            effect: .makePayment(verificationCode)
        )
    }
    
    func test_continue_shouldNotCallMakeDigestWithPaymentOnValidPaymentWithVerificationCode() {
        
        let makeDigestSpy = MakeDigestSpy(response: makePaymentDigest())
        let sut = makeSUT(
            getVerificationCode: { _ in makeVerificationCode() },
            makeDigest: makeDigestSpy.call
        )
        
        _ = sut.reduce(makeValidTransaction(makeContext()), .continue)
        
        XCTAssertNoDiff(makeDigestSpy.payloads, [])
    }
    
    func test_continue_shouldCallGetVerificationCodeWithPaymentOnValidPaymentWithVerificationCode() {
        
        let payment = makeContext()
        let getVerificationCodeSpy = GetVerificationCodeSpy(response: makeVerificationCode())
        let sut = makeSUT(getVerificationCode: getVerificationCodeSpy.call)
        
        _ = sut.reduce(makeValidTransaction(payment), .continue)
        
        XCTAssertNoDiff(getVerificationCodeSpy.payloads, [payment])
    }
    
    func test_continue_shouldResetPaymentAnsSetStatusToInflightOnValidPaymentWithShouldRestartPayment() {
        
        let state = makeValidTransaction(makeContext(shouldRestart: true))
        let initial = makeContext()
        let sut = makeSUT(resetPayment: { _ in initial })
        
        assertState(sut: sut, .continue, on: state) {
        
            $0.context = initial
            $0.status = .inflight
        }
    }
    
    func test_continue_shouldDeliverInitiatePaymentEffectWithPaymentDigestOnValidPaymentWithShouldRestartPayment() {
        
        let state = makeValidTransaction(makeContext(shouldRestart: true))
        let digest = makePaymentDigest()
        let sut = makeSUT(makeDigest: { _ in digest })
        
        assert(sut: sut, .continue, on: state, effect: .initiatePayment(digest))
    }
    
    func test_continue_shouldSetStatusToInflightOnValidPaymentWithoutShouldRestartPayment() {
        
        let state = makeValidTransaction(makeContext(shouldRestart: false))
        
        assertState(.continue, on: state) { $0.status = .inflight }
    }
    
    func test_continue_shouldDeliverContinueEffectOnValidPaymentWithoutShouldRestartPayment() {
        
        let state = makeValidTransaction(makeContext(shouldRestart: false))
        let digest = makePaymentDigest()
        let sut = makeSUT(makeDigest: { _ in digest })
        
        assert(sut: sut, .continue, on: state, effect: .continue(digest))
    }
    
    func test_continue_shouldNotCallStagePaymentOnInvalidTransaction() {
        
        let stagePaymentSpy = StagePaymentSpy(response: makeContext())
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        _ = sut.reduce(makeInvalidTransaction(), .continue)
        
        XCTAssertEqual(stagePaymentSpy.callCount, 0)
    }
    
    func test_continue_shouldNotCallStagePaymentOnFraudSuspectedTransaction() {
        
        let stagePaymentSpy = StagePaymentSpy(response: makeContext())
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        _ = sut.reduce(makeFraudSuspectedTransaction(), .continue)
        
        XCTAssertEqual(stagePaymentSpy.callCount, 0)
    }
    
    func test_continue_shouldNotCallStagePaymentOnResultFailureTransaction() {
        
        let stagePaymentSpy = StagePaymentSpy(response: makeContext())
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        _ = sut.reduce(makeResultFailureTransaction(), .continue)
        
        XCTAssertEqual(stagePaymentSpy.callCount, 0)
    }
    
    func test_continue_shouldNotCallStagePaymentOnResultSuccessTransaction() {
        
        let stagePaymentSpy = StagePaymentSpy(response: makeContext())
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        _ = sut.reduce(makeResultSuccessTransaction(), .continue)
        
        XCTAssertEqual(stagePaymentSpy.callCount, 0)
    }
    
    func test_continue_shouldNotCallStagePaymentOnServerErrorTransaction() {
        
        let stagePaymentSpy = StagePaymentSpy(response: makeContext())
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        _ = sut.reduce(makeServerErrorTransaction(), .continue)
        
        XCTAssertEqual(stagePaymentSpy.callCount, 0)
    }
    
    func test_continue_shouldCallStagePaymentWithPaymentOnValidTransaction() {
        
        let payment = makeContext()
        let stagePaymentSpy = StagePaymentSpy(response: makeContext())
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        _ = sut.reduce(makeValidTransaction(payment), .continue)
        
        XCTAssertNoDiff(stagePaymentSpy.payloads, [payment])
    }
    
    func test_continue_shouldSetStatusToInflightAndChangePaymentToStagedOnValidTransaction() {
        
        let staged = makeContext()
        let stagePaymentSpy = StagePaymentSpy(response: staged)
        let sut = makeSUT(stagePayment: stagePaymentSpy.call)
        
        assertState(sut: sut, .continue, on: makeValidTransaction(makeContext())) {
            
            $0.status = .inflight
            $0.context = staged
        }
    }
    
    // MARK: - dismissRecoverableError
    
    func test_dismissRecoverableError_shouldNotChangeResultFailureState() {
        
        assertState(.dismissRecoverableError, on: makeResultFailureTransaction())
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(.dismissRecoverableError, on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_dismissRecoverableError_shouldNotChangeResultSuccessState() {
        
        assertState(.dismissRecoverableError, on: makeResultSuccessTransaction())
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(.dismissRecoverableError, on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_dismissRecoverableError_shouldNotChangeFraudSuspectedState() {
        
        assertState(.dismissRecoverableError, on: makeFraudSuspectedTransaction())
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffectOnFraudSuspectedState() {
        
        assert(.dismissRecoverableError, on: makeFraudSuspectedTransaction(), effect: nil)
    }
    
    func test_dismissRecoverableError_shouldNotChangeNilStatusState() {
        
        assertState(.dismissRecoverableError, on: makeNilStatusTransaction())
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffectOnNilStatusState() {
        
        assert(.dismissRecoverableError, on: makeNilStatusTransaction(), effect: nil)
    }
    
    func test_dismissRecoverableError_shouldResetServerErrorStatus() {
        
        assertState(.dismissRecoverableError, on: makeServerErrorTransaction()) {
            
            $0.status = nil
        }
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffectOnServerErrorStatusState() {
        
        assert(.dismissRecoverableError, on: makeServerErrorTransaction(), effect: nil)
    }
    
    // MARK: - fraud
    
    func test_fraudCancel_shouldNotChangeResultFailureState() {
        
        assertState(makeFraudCancelTransactionEvent(), on: makeResultFailureTransaction())
    }
    
    func test_fraudCancel_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(makeFraudCancelTransactionEvent(), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_fraudCancel_shouldNotChangeResultSuccessState() {
        
        assertState(makeFraudCancelTransactionEvent(), on: makeResultSuccessTransaction())
    }
    
    func test_fraudCancel_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(makeFraudCancelTransactionEvent(), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_fraudCancel_shouldNotChangeNonFraudSuspectState() {
        
        assertState(
            makeFraudCancelTransactionEvent(),
            on: makeNonFraudSuspectedTransaction()
        )
    }
    
    func test_fraudCancel_shouldNotDeliverEffectOnNonFraudSuspect() {
        
        assert(
            makeFraudCancelTransactionEvent(),
            on: makeNonFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_fraudCancel_shouldSetStatusToFraudTerminatedOnFraudSuspect() {
        
        assertState(makeFraudCancelTransactionEvent(), on: makeFraudSuspectedTransaction()) {
            
            $0.status = .result(.failure(.fraud(.cancelled)))
        }
    }
    
    func test_fraudCancel_shouldNotDeliverEffectOnFraudSuspect() {
        
        assert(
            makeFraudCancelTransactionEvent(),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_fraudContinue_shouldNotChangeResultFailureState() {
        
        assertState(makeFraudContinueTransactionEvent(), on: makeResultFailureTransaction())
    }
    
    func test_fraudContinue_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(makeFraudContinueTransactionEvent(), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_fraudContinue_shouldNotChangeResultSuccessState() {
        
        assertState(makeFraudContinueTransactionEvent(), on: makeResultSuccessTransaction())
    }
    
    func test_fraudContinue_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(makeFraudContinueTransactionEvent(), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_fraudContinue_shouldNotChangeNonFraudSuspectState() {
        
        assertState(
            makeFraudContinueTransactionEvent(),
            on: makeNonFraudSuspectedTransaction()
        )
    }
    
    func test_fraudContinue_shouldNotDeliverEffectOnNonFraudSuspect() {
        
        assert(
            makeFraudContinueTransactionEvent(),
            on: makeNonFraudSuspectedTransaction(),
            effect: nil)
    }
    
    func test_fraudContinue_shouldResetStatusOnFraudSuspect() {
        
        assertState(makeFraudContinueTransactionEvent(), on: makeFraudSuspectedTransaction()) {
            
            $0.status = nil
        }
    }
    
    func test_fraudContinue_shouldNotDeliverEffectOnFraudSuspect() {
        
        assert(
            makeFraudContinueTransactionEvent(),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_fraudExpired_shouldNotChangeResultFailureState() {
        
        assertState(makeFraudExpiredTransactionEvent(), on: makeResultFailureTransaction())
    }
    
    func test_fraudExpired_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(makeFraudExpiredTransactionEvent(), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_fraudExpired_shouldNotChangeResultSuccessState() {
        
        assertState(makeFraudExpiredTransactionEvent(), on: makeResultSuccessTransaction())
    }
    
    func test_fraudExpired_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(makeFraudExpiredTransactionEvent(), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_fraudExpired_shouldNotChangeNonFraudSuspectState() {
        
        assertState(
            makeFraudExpiredTransactionEvent(),
            on: makeNonFraudSuspectedTransaction()
        )
    }
    
    func test_fraudExpired_shouldNotDeliverEffectOnNonFraudSuspect() {
        
        assert(
            makeFraudExpiredTransactionEvent(),
            on: makeNonFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_fraudExpired_shouldSetStatusToFraudTerminatedOnFraudSuspect() {
        
        assertState(makeFraudExpiredTransactionEvent(), on: makeFraudSuspectedTransaction()) {
            
            $0.status = .result(.failure(.fraud(.expired)))
        }
    }
    
    func test_fraudExpired_shouldNotDeliverEffectOnFraudSuspect() {
        
        assert(
            makeFraudExpiredTransactionEvent(),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldNotChangeResultFailureState() {
        
        assertState(.initiatePayment, on: makeResultFailureTransaction())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(.initiatePayment, on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeResultSuccessState() {
        
        assertState(.initiatePayment, on: makeResultSuccessTransaction())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(.initiatePayment, on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_initiatePayment_shouldSetStatusToInflight() {
        
        assertState(.initiatePayment, on: makeTransaction()) {
            
            $0.status = .inflight
        }
    }
    
    func test_initiatePayment_shouldDeliverEffect() {
        
        let digest = makePaymentDigest()
        let sut = makeSUT(makeDigest: { _ in digest })
        
        assert(sut: sut, .initiatePayment, on: makeTransaction(), effect: .initiatePayment(digest))
    }
    
    func test_initiatePayment_shouldNotChangeFraudSuspectedStatusState() {
        
        assertState(.initiatePayment, on: makeFraudSuspectedTransaction())
    }
    
    func test_initiatePayment_shouldDeliverEffectOnFraudSuspectedStatusState() {
        
        assert(.initiatePayment, on: makeFraudSuspectedTransaction(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeStateOnResultFailureStatus() {
        
        assertState(.initiatePayment, on: makeResultFailureTransaction())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnResultFailureStatus() {
        
        assert(.initiatePayment, on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeStateOnResultSuccessStatus() {
        
        assertState(.initiatePayment, on: makeResultSuccessTransaction())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnResultSuccessStatus() {
        
        assert(.initiatePayment, on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_initiatePayment_shouldNotChangeStateOnServerErrorStatus() {
        
        assertState(.initiatePayment, on: makeServerErrorTransaction())
    }
    
    func test_initiatePayment_shouldNotDeliverEffectOnServerErrorStatus() {
        
        assert(.initiatePayment, on: makeServerErrorTransaction(), effect: nil)
    }
    
    // MARK: - payment
    
    func test_payment_shouldNotChangeResultFailureState() {
        
        assertState(makePaymentTransactionEvent(), on: makeResultFailureTransaction())
    }
    
    func test_payment_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(makePaymentTransactionEvent(), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_payment_shouldNotChangeResultSuccessState() {
        
        assertState(makePaymentTransactionEvent(), on: makeResultSuccessTransaction())
    }
    
    func test_payment_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(makePaymentTransactionEvent(), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_payment_shouldCallPaymentReduceWithPaymentAndEvent() {
        
        let (payment, event) = (makeContext(), makePaymentEvent())
        let paymentReduceSpy = PaymentReduceSpy(response: (payment, nil))
        let sut = makeSUT(paymentReduce: paymentReduceSpy.call)
        
        _ = sut.reduce(makeTransaction(payment), .payment(event))
        
        XCTAssertNoDiff(paymentReduceSpy.payloads.map(\.0), [payment])
        XCTAssertNoDiff(paymentReduceSpy.payloads.map(\.1), [event])
    }
    
    func test_payment_shouldCallValidateWithUpdatedPayment() {
        
        let (payment, updated) = (makeContext(), makeContext())
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(
            paymentReduce: { _,_ in return (updated, nil) },
            validatePayment: validatePaymentSpy.call
        )
        
        _ = sut.reduce(makeTransaction(payment), .payment(makePaymentEvent()))
        
        XCTAssertNoDiff(validatePaymentSpy.payloads, [updated])
        XCTAssertNotEqual(payment, updated)
    }
    
    func test_payment_shouldNotChangeStateOnFraudSuspectedStatus() {
        
        let sut = makeSUT(paymentReduce: { _,_ in (makeContext(), nil) })
        
        assertState(
            sut: sut,
            makePaymentTransactionEvent(),
            on: makeFraudSuspectedTransaction()
        )
    }
    
    func test_payment_shouldSetPaymentToPaymentReducePayment() {
        
        let newPayment = makeContext()
        let sut = makeSUT(paymentReduce: { _,_ in (newPayment, nil) })
        
        assertState(sut: sut, makePaymentTransactionEvent(), on: makeTransaction()) {
            
            $0.context = newPayment
        }
    }
    
    func test_payment_shouldNotChangeStatusOnShouldRestartFalseAndWouldNeedToRestartFalse() {
        
        let newPayment = makeContext(shouldRestart: false)
        let sut = makeSUT(
            paymentReduce: { _,_ in (newPayment, nil) },
            wouldNeedRestart: { _ in false }
        )
        
        assertState(sut: sut, makePaymentTransactionEvent(), on: makeTransaction()) {
            
            $0.context = newPayment
        }
    }
    
//    func test_payment_shouldSetStatusToAwaitingConfirmationOnShouldRestartFalseAndWouldNeedToRestartTrue() {
//        
//        let newPayment = makePayment(shouldRestart: false)
//        let sut = makeSUT(
//            paymentReduce: { _,_ in (newPayment, nil) },
//            wouldNeedRestart: { _ in true }
//        )
//        
//        assertState(sut: sut, makePaymentTransactionEvent(), on: makeTransaction()) {
//            
//            $0.payment = newPayment
//            $0.status = .awaitingPaymentRestartConfirmation
//        }
//    }
    
    func test_payment_shouldNotChangeStatusOnShouldRestartTrueAndWouldNeedToRestartFalse() {
        
        let newPayment = makeContext(shouldRestart: true)
        let sut = makeSUT(
            paymentReduce: { _,_ in (newPayment, nil) },
            wouldNeedRestart: { _ in false }
        )
        
        assertState(sut: sut, makePaymentTransactionEvent(), on: makeTransaction()) {
            
            $0.context = newPayment
        }
    }
    
    func test_payment_shouldNotChangeStatusOnShouldRestartTrueAndWouldNeedToRestartTrue() {
        
        let newPayment = makeContext(shouldRestart: true)
        let sut = makeSUT(
            paymentReduce: { _,_ in (newPayment, nil) },
            wouldNeedRestart: { _ in true }
        )
        
        assertState(sut: sut, makePaymentTransactionEvent(), on: makeTransaction()) {
            
            $0.context = newPayment
        }
    }
    
    func test_payment_shouldNotDeliverEffectOnFraudSuspectedStatus() {
        
        let sut = makeSUT(paymentReduce: { _,_ in (makeContext(), makePaymentTransactionEffect()) })
        
        assert(
            sut: sut,
            makePaymentTransactionEvent(),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_payment_shouldDeliverPaymentReduceEffect() {
        
        let effect = makePaymentTransactionEffect()
        let sut = makeSUT(paymentReduce: { _,_ in (makeContext(), effect) })
        
        assert(
            sut: sut,
            makePaymentTransactionEvent(),
            on: makeTransaction(),
            effect: effect
        )
    }
    
    func test_payment_shouldSetPaymentValidationToValidateResult_notValid() {
        
        let sut = makeSUT(validatePayment: { _ in false })
        
        let (state, _) = sut.reduce(makeTransaction(), .payment(makePaymentEvent()))
        
        XCTAssertFalse(isValid(state))
    }
    
    func test_payment_shouldSetPaymentValidationToValidateResult_valid() {
        
        let sut = makeSUT(validatePayment: { _ in true })
        
        let (state, _) = sut.reduce(makeTransaction(), .payment(makePaymentEvent()))
        
        XCTAssertTrue(isValid(state))
    }
    
    // MARK: - paymentRestartConfirmation
    
    func test_paymentRestartConfirmation_shouldNotChangeNonAwaitingStateOnResetDenial() {
        
        assertState(.paymentRestartConfirmation(false), on: makeTransaction())
    }
    
    func test_paymentRestartConfirmation_shouldNotDeliverEffectOnNonAwaitingStateOnResetDenial() {
        
        assert(.paymentRestartConfirmation(false), on: makeTransaction(), effect: nil)
    }
    
    func test_paymentRestartConfirmation_shouldNotChangeNonAwaitingStateOnResetConfirmation() {
        
        assertState(.paymentRestartConfirmation(true), on: makeTransaction())
    }
    
    func test_paymentRestartConfirmation_shouldNotDeliverEffectOnNonAwaitingStateOnResetConfirmation() {
        
        assert(.paymentRestartConfirmation(true), on: makeTransaction(), effect: nil)
    }
    
    func test_paymentRestartConfirmation_shouldResetPaymentStatusOnResetDenial() {
        
        let state = makeTransaction(status: .awaitingPaymentRestartConfirmation)
        let prevPayment = makeContext()
        let sut = makeSUT(restorePayment: { _ in prevPayment })
        
        assertState(sut: sut, .paymentRestartConfirmation(false), on: state) {
            
            $0.context = prevPayment
            $0.status = nil
        }
    }
    
    func test_paymentRestartConfirmation_shouldNotDeliverEffectOnResetDenialOnAwaitingState() {
        
        let state = makeTransaction(status: .awaitingPaymentRestartConfirmation)
        
        assert(.paymentRestartConfirmation(false), on: state, effect: nil)
    }
    
    func test_paymentRestartConfirmation_true_shouldSetShouldRestartAndNilStatus() {
        
        let initial = makeContext()
        let state = makeTransaction(status: .awaitingPaymentRestartConfirmation)
        let sut = makeSUT(resetPayment: { _ in initial })
                
        assertState(sut: sut, .paymentRestartConfirmation(true), on: state) {
            
            $0.context.shouldRestart = true
            $0.status = nil
        }
    }
        
    func test_paymentRestartConfirmation_shouldNotDeliverEffectOnResetConfirmationOnAwaitingState() {
        
        let state = makeTransaction(status: .awaitingPaymentRestartConfirmation)
        
        assert(.paymentRestartConfirmation(true), on: state, effect: nil)
    }
    
    // MARK: - updatePayment
    
    func test_update_shouldNotChangeResultFailureStateOnUpdateConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(), on: makeResultFailureTransaction())
    }
    
    func test_update_shouldNotDeliverEffectOnResultFailureStateOnUpdateConnectivityErrorFailure() {
        
        assert(makeUpdateFailureTransactionEvent(), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_update_shouldNotChangeResultSuccessStateOnUpdateConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(), on: makeResultSuccessTransaction())
    }
    
    func test_update_shouldNotDeliverEffectOnResultSuccessStateOnUpdateConnectivityErrorFailure() {
        
        assert(makeUpdateFailureTransactionEvent(), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_update_shouldNotChangeStateOnFraudSuspectedStatusOnUpdateConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(), on: makeFraudSuspectedTransaction())
    }
    
    func test_update_shouldChangeStatusToTerminatedUpdateFailureOnUpdateConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(), on: makeTransaction()) {
            
            $0.status = .result(.failure(.updatePaymentFailure))
        }
    }
    
    func test_update_shouldNotCallValidateOnUpdateConnectivityErrorFailure() {
        
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(validatePayment: validatePaymentSpy.call)
        
        _ = sut.reduce(makeTransaction(), makeUpdateFailureTransactionEvent())
        
        XCTAssert(validatePaymentSpy.payloads.isEmpty)
    }
    
    func test_update_shouldNotCallFraudCheckOnUpdateConnectivityErrorFailure() {
        
        let checkFraudSpy = CheckFraudSpy(response: false)
        let sut = makeSUT(checkFraud: checkFraudSpy.call)
        
        _ = sut.reduce(makeTransaction(), makeUpdateFailureTransactionEvent())
        
        XCTAssert(checkFraudSpy.payloads.isEmpty)
    }
    
    func test_update_shouldNotChangeResultFailureStateOnUpdateServerErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(anyMessage()), on: makeResultFailureTransaction())
    }
    
    func test_update_shouldNotDeliverEffectOnResultFailureStateOnUpdateServerErrorFailure() {
        
        assert(makeUpdateFailureTransactionEvent(anyMessage()), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_update_shouldNotChangeResultSuccessStateOnUpdateServerErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(anyMessage()), on: makeResultSuccessTransaction())
    }
    
    func test_update_shouldNotDeliverEffectOnResultSuccessStateOnUpdateServerErrorFailure() {
        
        assert(makeUpdateFailureTransactionEvent(anyMessage()), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_update_shouldNotChangeStateOnFraudSuspectedStatusOnUpdateServerErrorFailure() {
        
        assertState(makeUpdateFailureTransactionEvent(anyMessage()), on: makeFraudSuspectedTransaction())
    }
    
    func test_update_shouldChangeStatusToServerErrorOnUpdateServerErrorFailure() {
        
        let message = anyMessage()
        
        assertState(makeUpdateFailureTransactionEvent(message), on: makeTransaction()) {
            
            $0.status = .serverError(message)
        }
    }
    
    func test_update_shouldNotCallValidateOnUpdateServerErrorFailure() {
        
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(validatePayment: validatePaymentSpy.call(payload:))
        
        _ = sut.reduce(makeTransaction(), makeUpdateFailureTransactionEvent(anyMessage()))
        
        XCTAssert(validatePaymentSpy.payloads.isEmpty)
    }
    
    func test_update_shouldNotCallFraudCheckOnUpdateServerErrorFailure() {
        
        let checkFraudSpy = CheckFraudSpy(response: false)
        let sut = makeSUT(checkFraud: checkFraudSpy.call)
        
        _ = sut.reduce(makeTransaction(), makeUpdateFailureTransactionEvent(anyMessage()))
        
        XCTAssert(checkFraudSpy.payloads.isEmpty)
    }
    
    func test_update_shouldCallUpdateWithPaymentAndUpdate() {
        
        let (payment, update) = (makeContext(), makeUpdate())
        let updatePaymentSpy = UpdatePaymentSpy(response: makeContext())
        let sut = makeSUT(updatePayment: updatePaymentSpy.call)
        
        _ = sut.reduce(makeTransaction(payment), makeUpdateTransactionEvent(update))
        
        XCTAssertNoDiff(updatePaymentSpy.payloads.map(\.0), [payment])
        XCTAssertNoDiff(updatePaymentSpy.payloads.map(\.1), [update])
    }
    
    func test_update_shouldCallValidateWithUpdatedPayment() {
        
        let (payment, updated) = (makeContext(), makeContext())
        let validatePaymentSpy = ValidatePaymentSpy(response: false)
        let sut = makeSUT(
            updatePayment: { _, _ in updated },
            validatePayment: validatePaymentSpy.call
        )
        
        _ = sut.reduce(makeTransaction(payment), makeUpdateTransactionEvent())
        
        XCTAssertNoDiff(validatePaymentSpy.payloads, [updated])
        XCTAssertNotEqual(payment, updated)
    }
    
    func test_update_shouldCallFraudCheckWithUpdated() {
        
        let update = makeUpdate()
        let checkFraudSpy = CheckFraudSpy(response: false)
        let sut = makeSUT(checkFraud: checkFraudSpy.call)
        
        _ = sut.reduce(makeTransaction(), makeUpdateTransactionEvent(update))
        
        XCTAssertNoDiff(checkFraudSpy.payloads, [update])
    }
    
    func test_update_shouldNotChangeStateOnFraudSuspectedStatus() {
        
        let sut = makeSUT(updatePayment: { _, _ in makeContext() })
        
        assertState(sut: sut, makeUpdateTransactionEvent(), on: makeFraudSuspectedTransaction())
    }
    
    func test_update_shouldNotChangeResultFailureState() {
        
        assertState(makeUpdateTransactionEvent(), on: makeResultFailureTransaction())
    }
    
    func test_update_shouldNotDeliverEffectOnResultFailureState() {
        
        assert(makeUpdateTransactionEvent(), on: makeResultFailureTransaction(), effect: nil)
    }
    
    func test_update_shouldNotChangeResultSuccessState() {
        
        assertState(makeUpdateTransactionEvent(), on: makeResultSuccessTransaction())
    }
    
    func test_update_shouldNotDeliverEffectOnResultSuccessState() {
        
        assert(makeUpdateTransactionEvent(), on: makeResultSuccessTransaction(), effect: nil)
    }
    
    func test_update_shouldSetPaymentToUpdatedValue() {
        
        let (payment, updated) = (makeContext(), makeContext())
        let sut = makeSUT(updatePayment: { _, _ in updated })
        
        assertState(sut: sut, makeUpdateTransactionEvent(), on: makeTransaction(payment)) {
            
            $0.context = updated
        }
        XCTAssertNotEqual(payment, updated)
    }
    
    func test_update_shouldSetPaymentValidationToValidateResult_notValid() {
        
        let sut = makeSUT(validatePayment: { _ in false })
        
        let (state, _) = sut.reduce(makeTransaction(), makeUpdateTransactionEvent())
        
        XCTAssertFalse(isValid(state))
    }
    
    func test_update_shouldSetPaymentValidationToValidateResult_valid() {
        
        let sut = makeSUT(validatePayment: { _ in true })
        
        let (state, _) = sut.reduce(makeTransaction(), makeUpdateTransactionEvent())
        
        XCTAssertTrue(isValid(state))
    }
    
    func test_update_shouldSetFraudToCheckFraudResult_notSuspected() {
        
        let sut = makeSUT(checkFraud: { _ in false })
        
        let (state, _) = sut.reduce(makeTransaction(), makeUpdateTransactionEvent())
        
        XCTAssertFalse(isFraudSuspected(state))
    }
    
    func test_update_shouldSetFraudToCheckFraudResult_suspected() {
        
        let context = makeContext()
        let sut = makeSUT(checkFraud: { _ in true })
        
        let (state, _) = sut.reduce(makeTransaction(context), makeUpdateTransactionEvent())
        
        XCTAssertTrue(isFraudSuspected(state))
    }
    
    func test_update_shouldNotDeliverEffectOnFraudSuspectedStatusOnConnectivityErrorFailure() {
        
        assert(
            makeUpdateFailureTransactionEvent(),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        assert(
            makeUpdateFailureTransactionEvent(),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnFraudSuspectedStatusOnServerErrorFailure() {
        
        assert(
            makeUpdateFailureTransactionEvent(anyMessage()),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnServerErrorFailure() {
        
        assert(
            makeUpdateFailureTransactionEvent(anyMessage()),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnFraudSuspectedStatus() {
        
        assert(
            makeUpdateTransactionEvent(),
            on: makeFraudSuspectedTransaction(),
            effect: nil
        )
    }
    
    func test_update_shouldNotDeliverEffectOnUpdate() {
        
        assert(
            makeUpdateTransactionEvent(),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    // MARK: - verificationCode: request
    
    func test_verificationCode_request_shouldNotChangeState() {
        
        assertState(.verificationCode(.request), on: makeTransaction())
    }
    
    func test_verificationCode_request_shouldDeliverEffect() {
        
        assert(
            .verificationCode(.request), 
            on: makeTransaction(),
            effect: .getVerificationCode
        )
    }
    
    // MARK: - verificationCode: receive
    
    func test_verificationCode_receive_shouldChangeStatusOnConnectivityError() {
        
        assertState(
            .verificationCode(.receive(.failure(.connectivityError))),
            on: makeTransaction()
        ) {
            $0.status = .result(.failure(.transactionFailure))
        }
    }
    
    func test_verificationCode_receive_shouldNotDeliverEffectOnConnectivityError() {
        
        assert(
            .verificationCode(.receive(.failure(.connectivityError))),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    func test_verificationCode_receive_shouldChangeStatusOnServerError() {
        
        let message = anyMessage()
        
        assertState(
            .verificationCode(.receive(.failure(.serverError(message)))),
            on: makeTransaction()
        ) {
            $0.status = .result(.failure(.transactionFailure))
        }
    }
    
    func test_verificationCode_receive_shouldNotDeliverEffectOnServerError() {
        
        let message = anyMessage()

        assert(
            .verificationCode(.receive(.failure(.serverError(message)))),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    func test_verificationCode_receive_shouldNotChangeStateOnSuccess() {
        
        assertState(
            .verificationCode(.receive(.success(Int.random(in: 1...10)))),
            on: makeTransaction()
        )
    }
    
    func test_verificationCode_receive_shouldNotDeliverEffectOnSuccess() {
        
        assert(
            .verificationCode(.receive(.success(Int.random(in: 1...10)))),
            on: makeTransaction(),
            effect: nil
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = _TransactionReducer
    
    private typealias State = _Transaction
    private typealias Event = _TransactionEvent
    private typealias Effect = _TransactionEffect
    
    private typealias CheckFraudSpy = CallSpy<PaymentUpdate, Bool>
    private typealias MakeDigestSpy = CallSpy<Context, PaymentDigest>
    private typealias GetVerificationCodeSpy = CallSpy<Context, VerificationCode?>
    private typealias PaymentReduceSpy = CallSpy<(Context, PaymentEvent), (Context, SUT.Effect?)>
    private typealias ShouldRestartPaymentSpy = CallSpy<Context, Bool>
    private typealias StagePaymentSpy = CallSpy<Context, Context>
    private typealias UpdatePaymentSpy = CallSpy<(Context, PaymentUpdate), Context>
    private typealias ValidatePaymentSpy = CallSpy<Context, Bool>
    
    private typealias Inspector = PaymentInspector<Context, PaymentDigest, PaymentUpdate>
    
    private func makeSUT(
        checkFraud: @escaping Inspector.CheckFraud = { _ in false },
        getVerificationCode: @escaping Inspector.GetVerificationCode = { _ in nil },
        makeDigest: @escaping Inspector.MakeDigest = { _ in makePaymentDigest() },
        paymentReduce: @escaping SUT.PaymentReduce = { payment, _ in (payment, nil) },
        resetPayment: @escaping Inspector.ResetPayment = { _ in makeContext() },
        restorePayment: @escaping Inspector.RestorePayment = { _ in makeContext() },
        stagePayment: @escaping SUT.StagePayment = { $0 },
        updatePayment: @escaping SUT.UpdatePayment = { payment, _ in payment },
        validatePayment: @escaping Inspector.ValidatePayment = { _ in false },
        wouldNeedRestart: @escaping Inspector.WouldNeedRestart = { _ in false },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            paymentReduce: paymentReduce,
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            paymentInspector: .init(
                checkFraud: checkFraud,
                getVerificationCode: getVerificationCode,
                makeDigest: makeDigest,
                resetPayment: resetPayment,
                restorePayment: restorePayment,
                validatePayment: validatePayment,
                wouldNeedRestart: wouldNeedRestart
            )
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
