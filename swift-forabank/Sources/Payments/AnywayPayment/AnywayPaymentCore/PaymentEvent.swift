//
//  PaymentEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import Tagged

public enum PaymentEvent<DocumentStatus, OperationDetails, Update> {
    
    case update(UpdateResult)
    case completePayment(TransactionResult)
}

extension PaymentEvent {
    
    public struct TransactionDetails {
        
        public let documentStatus: DocumentStatus
        public let details: Details
        
        public init(
            documentStatus: DocumentStatus,
            details: Details
        ) {
            self.documentStatus = documentStatus
            self.details = details
        }
    }
    
    public struct TransactionFailure: Error, Equatable {
        
        public init() {}
    }
    
    public typealias TransactionResult = Result<TransactionDetails, TransactionFailure>

    public typealias UpdateResult = Result<Update, ServiceFailure>
}

public extension PaymentEvent.TransactionDetails {
    
    enum Details {
        
        case paymentOperationDetailID(PaymentOperationDetailID)
        case operationDetails(OperationDetails)
    }
}

public extension PaymentEvent.TransactionDetails.Details {
    
    typealias PaymentOperationDetailID = Tagged<_PaymentOperationDetailID, Int>
    enum _PaymentOperationDetailID {}
}

extension PaymentEvent: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable, Update: Equatable {}
extension PaymentEvent.TransactionDetails: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
extension PaymentEvent.TransactionDetails.Details: Equatable where OperationDetails: Equatable {}
