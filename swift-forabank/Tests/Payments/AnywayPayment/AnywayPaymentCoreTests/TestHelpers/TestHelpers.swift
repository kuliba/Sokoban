//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentDomain
import AnywayPaymentCore
import Foundation

// MARK: - Test Types

enum DocumentStatus: Equatable {
    
    case complete, inflight
}

struct OperationDetails: Equatable {
    
    let value: String
}

enum PaymentEffect {
    
    case select
}

enum PaymentEvent {
    
    case select
}

struct Payment: Equatable & RestartablePayment {
    
    let value: String
    var shouldRestart: Bool
}

struct PaymentDigest: Equatable {
    
    let value: String
}

struct PaymentUpdate: Equatable {
    
    let value: String
}

typealias OperationDetailID = Int

typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>
typealias Report = TransactionReport<DocumentStatus, _OperationInfo>
typealias _TransactionStatus = TransactionStatus<Report>

typealias _Transaction = Transaction<Payment, _TransactionStatus>
typealias _TransactionEvent = TransactionEvent<Report, PaymentEvent, PaymentUpdate>
typealias _TransactionEffect = TransactionEffect<PaymentDigest, PaymentEffect>

typealias _TransactionReducer = TransactionReducer<Report, Payment, PaymentEvent, PaymentEffect, PaymentDigest, PaymentUpdate>
typealias _TransactionEffectHandler = TransactionEffectHandler<Report, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>

typealias PaymentEffectHandleSpy = EffectHandlerSpy<PaymentEvent, PaymentEffect>

typealias PaymentInitiator = PaymentProcessing
typealias PaymentMaker = Spy<VerificationCode, Report?>
typealias PaymentProcessing = Spy<PaymentDigest, _TransactionEvent.UpdatePaymentResult>

// MARK: - Factories

func isValid(
    _ state: _Transaction
) -> Bool {
    
    state.isValid
}

func isFraudSuspected(
    _ state: _Transaction
) -> Bool {
    
    state.status == .fraudSuspected
}

func makeCompletePaymentFailureEvent(
) -> _TransactionEvent {
    
    .completePayment(nil)
}

func makeCompletePaymentReportEvent(
    _ report: TransactionReport<DocumentStatus, _OperationInfo>
) -> _TransactionEvent {
    
    .completePayment(report)
}

func makeContinueTransactionEffect(
    _ digest: PaymentDigest = makePaymentDigest()
) -> _TransactionEffect {
    
    .continue(digest)
}

func makeDetailID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> Int {
    
    .init(rawValue)
}

func makeDetailIDTransactionReport(
    status: DocumentStatus = .complete,
    _ id: Int = generateRandom11DigitNumber()
) -> TransactionReport<DocumentStatus, _OperationInfo> {
    
    .init(
        status: status,
        info: .detailID(.init(id))
    )
}

func makeFraudCancelTransactionEvent(
) -> _TransactionEvent {
    
    .fraud(.cancel)
}

func makeFraudContinueTransactionEvent(
) -> _TransactionEvent {
    
    .fraud(.continue)
}

func makeFraudExpiredTransactionEvent(
) -> _TransactionEvent {
    
    .fraud(.expired)
}

func makeFraudSuspectedTransaction(
    _ payment: Payment = makePayment()
) -> _Transaction {
    
    let state = makeTransaction(payment, status: .fraudSuspected)
    precondition(state.status == .fraudSuspected)
    return state
}

func makeInitiateTransactionEffect(
    _ digest: PaymentDigest = makePaymentDigest()
) -> _TransactionEffect {
    
    .initiatePayment(digest)
}

func makeInvalidTransaction(
    _ payment: Payment = makePayment()
) -> _Transaction {
    
    let state = makeTransaction(payment, isValid: false)
    precondition(!isValid(state))
    return state
}

func makeNilStatusTransaction(
    _ payment: Payment = makePayment()
) -> _Transaction {
    
    let state = makeTransaction(payment)
    precondition(state.status == nil)
    return state
}

func makeNonFraudSuspectedTransaction(
    _ payment: Payment = makePayment()
) -> _Transaction {
    
    let state = makeTransaction(payment)
    precondition(state.status != .fraudSuspected)
    return state
}

func makeOperationDetailsTransactionReport(
    status: DocumentStatus = .complete,
    _ value: String = UUID().uuidString
) -> TransactionReport<DocumentStatus, _OperationInfo> {
    
    .init(
        status: status,
        info: .details(makeOperationDetails(value))
    )
}

func makeOperationDetailsTransactionReport(
    status: DocumentStatus = .complete,
    _ operationDetails: OperationDetails
) -> TransactionReport<DocumentStatus, _OperationInfo> {
    
    .init(
        status: status,
        info: .details(operationDetails)
    )
}

func makeOperationDetails(
    _ value: String = UUID().uuidString
) -> OperationDetails {
    
    .init(value: value)
}

func makePaymentDigest(
    _ value: String = UUID().uuidString
) -> PaymentDigest {
    
    .init(value: value)
}

func makePaymentEffect(
) -> PaymentEffect {
    
    .select
}

func makePaymentTransactionEffect(
    _ effect: PaymentEffect = makePaymentEffect()
) -> _TransactionEffect {
    
    .payment(effect)
}

func makePaymentEvent(
) -> PaymentEvent {
    
    .select
}

func makePaymentTransactionEvent(
) -> _TransactionEvent {
    
    .payment(.select)
}

func makePayment(
    _ value: String = UUID().uuidString,
    shouldRestart: Bool = false
) -> Payment {
    
    .init(value: value, shouldRestart: shouldRestart)
}

func makeTransactionEffect(
    _ verificationCode: VerificationCode = makeVerificationCode()
) -> _TransactionEffect {
    
    .makePayment(verificationCode)
}

func makeTransaction(
    _ context: Payment = makePayment(),
    isValid: Bool = false,
    status: _TransactionStatus? = nil
) -> _Transaction {
    
    .init(context: context, isValid: isValid, status: status)
}

func makeResponse(
    _ documentStatus: DocumentStatus = .complete,
    id: Int = generateRandom11DigitNumber()
) -> TransactionPerformer<DocumentStatus, OperationDetailID, OperationDetails>.MakeTransferResponse {
    
    .init(
        status: documentStatus,
        detailID: id
    )
}

func makeResultFailureTransaction(
    _ payment: Payment = makePayment(),
    failure: _TransactionStatus.Terminated = .transactionFailure
) -> _Transaction {
    
    let state = makeTransaction(payment, status: .result(.failure(failure)))
    precondition(state.status == .result(.failure(failure)))
    return state
}

func makeResultSuccessTransaction(
    _ payment: Payment = makePayment(),
    report: TransactionReport<DocumentStatus, _OperationInfo> = makeDetailIDTransactionReport()
) -> _Transaction {
    
    let state = makeTransaction(payment, status: .result(.success(report)))
    precondition(state.status == .result(.success(report)))
    return state
}

func makeServerErrorTransaction(
    _ payment: Payment = makePayment(),
    _ message: String = anyMessage()
) -> _Transaction {
    
    let state = makeTransaction(payment, status: .serverError(message))
    precondition(state.status == .serverError(message))
    return state
}

func makeValidTransaction(
    _ payment: Payment = makePayment(),
    status: _TransactionStatus? = nil
) -> _Transaction {
    
    let state = makeTransaction(payment, isValid: true, status: status)
    precondition(isValid(state))
    return state
}

func makeVerificationCode(
    _ value: String = UUID().uuidString
) -> VerificationCode {
    
    .init(value)
}

func makeUpdate(
    _ value: String = UUID().uuidString
) -> PaymentUpdate {
    
    .init(value: value)
}

func makeUpdateFailureTransactionEvent(
    _ message: String? = nil
) -> _TransactionEvent {
    
    if let message {
        return .updatePayment(.failure(.serverError(message)))
    } else {
        return .updatePayment(.failure(.connectivityError))
    }
}

func makeUpdateTransactionEvent(
    _ update: PaymentUpdate = makeUpdate()
) -> _TransactionEvent {
    
    .updatePayment(.success(update))
}
