//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentCore
import Foundation

// MARK: - Test Types

enum DocumentStatus: Equatable {
    
    case complete, inflight
}

struct OperationDetails: Equatable {
    
    let value: String
}

// MARK: - Factories

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

func makeVerificationCode(
    _ value: String = UUID().uuidString
) -> VerificationCode {
    
    .init(value)
}
