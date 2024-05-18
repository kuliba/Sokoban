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

struct Payment: Equatable {
    
    let value: String
}

struct PaymentDigest: Equatable {
    
    let value: String
}

struct PaymentUpdate: Equatable {
    
    let value: String
}

// MARK: - Factories

func isValid(
    _ state: Transaction<DocumentStatus, OperationDetails, Payment>
) -> Bool {
    
    state.isValid
}

func isFraudSuspected(
    _ state: Transaction<DocumentStatus, OperationDetails, Payment>
) -> Bool {
    
    state.status == .fraudSuspected
}

func makeCompletePaymentFailureEvent(
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .completePayment(nil)
}

func makeCompletePaymentReportEvent(
    _ report: TransactionReport<DocumentStatus, OperationDetails>
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .completePayment(report)
}

func makeContinueTransactionEffect(
    _ digest: PaymentDigest = makePaymentDigest()
) -> TransactionEffect<PaymentDigest, PaymentEffect> {
    
    .continue(digest)
}

func makeDetailID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> TransactionReport<DocumentStatus, OperationDetails>.Details.PaymentOperationDetailID {
    
    .init(rawValue)
}

func makeDetailIDTransactionReport(
    documentStatus: DocumentStatus = .complete,
    _ id: Int = generateRandom11DigitNumber()
) -> TransactionReport<DocumentStatus, OperationDetails> {
    
    .init(
        documentStatus: documentStatus,
        details: .paymentOperationDetailID(.init(id))
    )
}

func makeFraudCancelTransactionEvent(
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .fraud(.cancel)
}

func makeFraudContinueTransactionEvent(
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .fraud(.continue)
}

func makeFraudExpiredTransactionEvent(
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .fraud(.expired)
}

func makeFraudSuspectedTransaction(
    _ payment: Payment = makePayment()
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment, status: .fraudSuspected)
    precondition(state.status == .fraudSuspected)
    return state
}

func makeInitiateTransactionEffect(
    _ digest: PaymentDigest = makePaymentDigest()
) -> TransactionEffect<PaymentDigest, PaymentEffect> {
    
    .initiatePayment(digest)
}

func makeInvalidTransaction(
    _ payment: Payment = makePayment()
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment, isValid: false)
    precondition(!isValid(state))
    return state
}

func makeNilStatusTransaction(
    _ payment: Payment = makePayment()
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment)
    precondition(state.status == nil)
    return state
}

func makeNonFraudSuspectedTransaction(
    _ payment: Payment = makePayment()
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment)
    precondition(state.status != .fraudSuspected)
    return state
}

func makeOperationDetailsTransactionReport(
    documentStatus: DocumentStatus = .complete,
    _ value: String = UUID().uuidString
) -> TransactionReport<DocumentStatus, OperationDetails> {
    
    .init(
        documentStatus: documentStatus,
        details: .operationDetails(makeOperationDetails(value))
    )
}

func makeOperationDetailsTransactionReport(
    documentStatus: DocumentStatus = .complete,
    _ operationDetails: OperationDetails
) -> TransactionReport<DocumentStatus, OperationDetails> {
    
    .init(
        documentStatus: documentStatus,
        details: .operationDetails(operationDetails)
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
) -> TransactionEffect<PaymentDigest, PaymentEffect> {
    
    .payment(effect)
}

func makePaymentEvent(
) -> PaymentEvent {
    
    .select
}

func makePaymentTransactionEvent(
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .payment(.select)
}

func makePayment(
    _ value: String = UUID().uuidString
) -> Payment {
    
    .init(value: value)
}

func makeTransactionEffect(
    _ verificationCode: VerificationCode = makeVerificationCode()
) -> TransactionEffect<PaymentDigest, PaymentEffect> {
    
    .makePayment(verificationCode)
}

func makeTransaction(
    _ payment: Payment = makePayment(),
    isValid: Bool = false,
    status: Transaction<DocumentStatus, OperationDetails, Payment>.Status? = nil
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    .init(payment: payment, isValid: isValid, status: status)
}

func makeResponse(
    _ documentStatus: DocumentStatus = .complete,
    id: Int = generateRandom11DigitNumber()
) -> TransactionPerformer<DocumentStatus, OperationDetails>.MakeTransferResponse {
    
    .init(
        documentStatus: documentStatus,
        paymentOperationDetailID: .init(id)
    )
}

func makeResultFailureTransaction(
    _ payment: Payment = makePayment(),
    failure: Transaction<DocumentStatus, OperationDetails, Payment>.Status.Terminated = .transactionFailure
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment, status: .result(.failure(failure)))
    precondition(state.status == .result(.failure(failure)))
    return state
}

func makeResultSuccessTransaction(
    _ payment: Payment = makePayment(),
    report: TransactionReport<DocumentStatus, OperationDetails> = makeDetailIDTransactionReport()
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment, status: .result(.success(report)))
    precondition(state.status == .result(.success(report)))
    return state
}

func makeServerErrorTransaction(
    _ payment: Payment = makePayment(),
    _ message: String = anyMessage()
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
    let state = makeTransaction(payment, status: .serverError(message))
    precondition(state.status == .serverError(message))
    return state
}

func makeValidTransaction(
    _ payment: Payment = makePayment(),
    status: Transaction<DocumentStatus, OperationDetails, Payment>.Status? = nil
) -> Transaction<DocumentStatus, OperationDetails, Payment> {
    
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
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    if let message {
        return .updatePayment(.failure(.serverError(message)))
    } else {
        return .updatePayment(.failure(.connectivityError))
    }
}

func makeUpdateTransactionEvent(
    _ update: PaymentUpdate = makeUpdate()
) -> TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    .updatePayment(.success(update))
}
