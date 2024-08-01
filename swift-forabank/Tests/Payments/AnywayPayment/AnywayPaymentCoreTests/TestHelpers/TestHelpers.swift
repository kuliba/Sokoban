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
typealias _TransactionStatus = TransactionStatus<Context, PaymentUpdate, Report>

typealias _Transaction = Transaction<Context, _TransactionStatus>
typealias _TransactionEvent = TransactionEvent<Report, PaymentEvent, PaymentUpdate>
typealias _TransactionEffect = TransactionEffect<PaymentDigest, PaymentEffect>

typealias _TransactionReducer = TransactionReducer<Report, Context, PaymentEvent, PaymentEffect, PaymentDigest, PaymentUpdate>
typealias _TransactionEffectHandler = TransactionEffectHandler<Report, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>

typealias PaymentEffectHandleSpy = EffectHandlerSpy<PaymentEvent, PaymentEffect>

typealias PaymentInitiator = PaymentProcessing
typealias PaymentMaker = Spy<VerificationCode, _TransactionEvent.TransactionResult>
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
    
    switch state.status {
    case .fraudSuspected: return true
    default: return false
    }
}

func completeWithReport(
    _ report: Report = makeDetailIDTransactionReport()
) -> _TransactionEvent {
    
    return .completePayment(.success(report))
}

func completeWithFailure(
    _ failure: _TransactionEvent.TransactionFailure = .terminal
) -> _TransactionEvent {
    
    return .completePayment(.failure(failure))
}

func makePaymentUpdate(
    _ value: String = anyMessage()
) -> PaymentUpdate {
    
    return .init(value: value)
}

func makeCompletePaymentFailureEvent(
    _ failure: _TransactionEvent.TransactionFailure = .terminal
) -> _TransactionEvent {
    
    return .completePayment(.failure(failure))
}

func makeCompletePaymentReportEvent(
    _ report: Report
) -> _TransactionEvent {
    
    return .completePayment(.success(report))
}

func makeContinueTransactionEffect(
    _ digest: PaymentDigest = makePaymentDigest()
) -> _TransactionEffect {
    
    .continue(digest)
}

func makeDetailID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> Int {
    
    return .init(rawValue)
}

func makeDetailIDTransactionReport(
    status: DocumentStatus = .complete,
    _ id: Int = generateRandom11DigitNumber()
) -> Report {
    
    return .init(
        status: status,
        info: .detailID(.init(id))
    )
}

func makeFraudCancelTransactionEvent(
) -> _TransactionEvent {
    
    return .fraud(.cancel)
}

func makeFraudContinueTransactionEvent(
) -> _TransactionEvent {
    
    return .fraud(.consent)
}

func makeFraudExpiredTransactionEvent(
) -> _TransactionEvent {
    
    return .fraud(.expired)
}

func makeFraudSuspectedTransaction(
    _ context: Context = makeContext(),
    _ update: PaymentUpdate = makePaymentUpdate()
) -> _Transaction {
    
    let state = makeTransaction(context, status: .fraudSuspected(update))
    precondition(state.status == .fraudSuspected(update))
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
    precondition(!state.isFraudSuspected)
    return state
}

extension _Transaction {
    
    var isFraudSuspected: Bool {
        
        switch status {
        case .fraudSuspected: return true
        default: return false
        }
    }
}

func makeOperationDetailsTransactionReport(
    status: DocumentStatus = .complete,
    _ value: String = UUID().uuidString
) -> Report {
    
    .init(
        status: status,
        info: .details(makeOperationDetails(value))
    )
}

func makeOperationDetailsTransactionReport(
    status: DocumentStatus = .complete,
    _ operationDetails: OperationDetails
) -> Report {
    
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
    
    return .init(
        context: context,
        isValid: isValid,
        status: status
    )
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
    report: Report = makeDetailIDTransactionReport()
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
