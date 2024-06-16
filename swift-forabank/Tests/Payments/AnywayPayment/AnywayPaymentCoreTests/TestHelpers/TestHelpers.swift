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

struct Context: Equatable & RestartablePayment {
    
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
typealias _TransactionStatus = TransactionStatus<Context, Report>

typealias _Transaction = Transaction<Context, _TransactionStatus>
typealias _TransactionEvent = TransactionEvent<Report, PaymentEvent, PaymentUpdate>
typealias _TransactionEffect = TransactionEffect<PaymentDigest, PaymentEffect>

typealias _TransactionReducer = TransactionReducer<Report, Context, PaymentEvent, PaymentEffect, PaymentDigest, PaymentUpdate>
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
    _ state: _Transaction,
    context: Context = makeContext()
) -> Bool {
    
    state.status == .fraudSuspected(context)
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
    _ context: Context = makeContext()
) -> _Transaction {
    
    let state = makeTransaction(context, status: .fraudSuspected(context))
    precondition(state.status == .fraudSuspected(context))
    return state
}

func makeInitiateTransactionEffect(
    _ digest: PaymentDigest = makePaymentDigest()
) -> _TransactionEffect {
    
    .initiatePayment(digest)
}

func makeInvalidTransaction(
    _ context: Context = makeContext()
) -> _Transaction {
    
    let state = makeTransaction(context, isValid: false)
    precondition(!isValid(state))
    return state
}

func makeNilStatusTransaction(
    _ context: Context = makeContext()
) -> _Transaction {
    
    let state = makeTransaction(context)
    precondition(state.status == nil)
    return state
}

func makeNonFraudSuspectedTransaction(
    _ context: Context = makeContext()
) -> _Transaction {
    
    let state = makeTransaction(context)
    precondition(state.status != .fraudSuspected(context))
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

func makeContext(
    _ value: String = UUID().uuidString,
    shouldRestart: Bool = false
) -> Context {
    
    .init(value: value, shouldRestart: shouldRestart)
}

func makeTransactionEffect(
    _ verificationCode: VerificationCode = makeVerificationCode()
) -> _TransactionEffect {
    
    .makePayment(verificationCode)
}

func makeTransaction(
    _ context: Context = makeContext(),
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
    _ context: Context = makeContext(),
    failure: _TransactionStatus.Terminated = .transactionFailure
) -> _Transaction {
    
    let state = makeTransaction(context, status: .result(.failure(failure)))
    precondition(state.status == .result(.failure(failure)))
    return state
}

func makeResultSuccessTransaction(
    _ context: Context = makeContext(),
    report: TransactionReport<DocumentStatus, _OperationInfo> = makeDetailIDTransactionReport()
) -> _Transaction {
    
    let state = makeTransaction(context, status: .result(.success(report)))
    precondition(state.status == .result(.success(report)))
    return state
}

func makeServerErrorTransaction(
    _ context: Context = makeContext(),
    _ message: String = anyMessage()
) -> _Transaction {
    
    let state = makeTransaction(context, status: .serverError(message))
    precondition(state.status == .serverError(message))
    return state
}

func makeValidTransaction(
    _ context: Context = makeContext(),
    status: _TransactionStatus? = nil
) -> _Transaction {
    
    let state = makeTransaction(context, isValid: true, status: status)
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
