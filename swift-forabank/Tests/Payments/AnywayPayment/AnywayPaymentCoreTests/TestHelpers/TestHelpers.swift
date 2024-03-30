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

struct Payment: Equatable {
    
    let value: String
}

struct Update: Equatable {
    
    let value: String
}

// MARK: - Factories

func completePaymentFailureEvent(
) -> PaymentEvent<DocumentStatus, OperationDetails, Update> {
    
    .completePayment(nil)
}

func completePaymentReportEvent(
    _ report: TransactionReport<DocumentStatus, OperationDetails>
) -> PaymentEvent<DocumentStatus, OperationDetails, Update> {
    
    .completePayment(report)
}

func continueEffect(
    _ digest: Digest = makeDigest()
) -> PaymentEffect<Digest> {
    
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

func makePaymentEffect(
    _ verificationCode: VerificationCode = makeVerificationCode()
) -> PaymentEffect<Digest> {
    
    .makePayment(verificationCode)
}

func makePaymentState(
    _ payment: Payment = makePayment(),
    status: PaymentState<Payment, DocumentStatus, OperationDetails>.Status? = nil
) -> PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    .init(payment: payment, status: status)
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

func makePayment(
    _ value: String = UUID().uuidString
) -> Payment {
    
    .init(value: value)
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
) -> PaymentEvent<DocumentStatus, OperationDetails, Update> {
    
    if let message {
        return .update(.failure(.serverError(message)))
    } else {
        return .update(.failure(.connectivityError))
    }
}

func makeUpdateEvent(
    _ update: Update = makeUpdate()
) -> PaymentEvent<DocumentStatus, OperationDetails, Update> {
    
    .update(.success(update))
}
