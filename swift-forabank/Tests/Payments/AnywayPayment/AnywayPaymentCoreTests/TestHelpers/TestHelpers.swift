//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentCore
import Foundation

// MARK: - Test Types

struct Digest: Equatable {
    
    let value: String
}

enum DocumentStatus: Equatable {
    
    case complete, inflight
}

struct OperationDetails: Equatable {
    
    let value: String
}

enum ParameterEffect {
    
    case select
}

enum ParameterEvent {
    
    case select
}

struct Payment: Equatable {
    
    let value: String
}

struct Update: Equatable {
    
    let value: String
}

// MARK: - Factories

func isValid(
    _ state: PaymentState<Payment, DocumentStatus, OperationDetails>
) -> Bool {
    
    state.isValid
}

func isFraudSuspected(
    _ state: PaymentState<Payment, DocumentStatus, OperationDetails>
) -> Bool {
    
    state.status == .fraudSuspected
}

func makeCompletePaymentFailureEvent(
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .completePayment(nil)
}

func makeCompletePaymentReportEvent(
    _ report: TransactionReport<DocumentStatus, OperationDetails>
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .completePayment(report)
}

func makeContinuePaymentEffect(
    _ digest: Digest = makeDigest()
) -> PaymentEffect<Digest, ParameterEffect> {
    
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

func makeDigest(
    _ value: String = UUID().uuidString
) -> Digest {
    
    .init(value: value)
}

func makeFraudCancelEvent(
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .fraud(.cancel)
}

func makeFraudContinueEvent(
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .fraud(.continue)
}

func makeFraudExpiredEvent(
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .fraud(.expired)
}

func makeFraudSuspectedPaymentState(
    _ payment: Payment = makePayment()
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment, status: .fraudSuspected)
    precondition(state.status == .fraudSuspected)
    return state
}

func makeInitiatePaymentEffect(
    _ digest: Digest = makeDigest()
) -> PaymentEffect<Digest, ParameterEffect> {
    
    .initiatePayment(digest)
}

func makeInvalidPaymentState(
    _ payment: Payment = makePayment()
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment, isValid: false)
    precondition(!isValid(state))
    return state
}

func makeNonFraudSuspectedPaymentState(
    _ payment: Payment = makePayment()
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment)
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

func makeParameterEffect(
) -> ParameterEffect {
    
    .select
}

func makeParameterPaymentEffect(
    _ effect: ParameterEffect = makeParameterEffect()
) -> PaymentEffect<Digest, ParameterEffect> {
    
    .parameter(effect)
}

func makeParameterEvent(
) -> ParameterEvent {
    
    .select
}

func makeParameterPaymentEvent(
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .parameter(.select)
}

func makePayment(
    _ value: String = UUID().uuidString
) -> Payment {
    
    .init(value: value)
}

func makePaymentEffect(
    _ verificationCode: VerificationCode = makeVerificationCode()
) -> PaymentEffect<Digest, ParameterEffect> {
    
    .makePayment(verificationCode)
}

func makePaymentState(
    _ payment: Payment = makePayment(),
    isValid: Bool = false,
    status: PaymentState<Payment, DocumentStatus, OperationDetails>.Status? = nil
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
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

func makeResultFailureState(
    _ payment: Payment = makePayment(),
    failure: PaymentState<Payment, DocumentStatus, OperationDetails>.Status.Terminated = .transactionFailure
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment, status: .result(.failure(failure)))
    precondition(state.status == .result(.failure(failure)))
    return state
}

func makeResultSuccessState(
    _ payment: Payment = makePayment(),
    report: TransactionReport<DocumentStatus, OperationDetails> = makeDetailIDTransactionReport()
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment, status: .result(.success(report)))
    precondition(state.status == .result(.success(report)))
    return state
}

func makeServerErrorState(
    _ payment: Payment = makePayment(),
    _ message: String = anyMessage()
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment, status: .serverError(message))
    precondition(state.status == .serverError(message))
    return state
}

func makeValidPaymentState(
    _ payment: Payment = makePayment(),
    status: PaymentState<Payment, DocumentStatus, OperationDetails>.Status? = nil
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    let state = makePaymentState(payment, isValid: true, status: status)
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
) -> Update {
    
    .init(value: value)
}

func makeUpdateFailureEvent(
    _ message: String? = nil
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    if let message {
        return .updatePayment(.failure(.serverError(message)))
    } else {
        return .updatePayment(.failure(.connectivityError))
    }
}

func makeUpdateEvent(
    _ update: Update = makeUpdate()
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .updatePayment(.success(update))
}
