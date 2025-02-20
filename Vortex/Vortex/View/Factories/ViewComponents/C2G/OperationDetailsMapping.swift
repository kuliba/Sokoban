//
//  OperationDetailsMapping.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

// MARK: - Transaction Details

extension OperationDetailDomain.State.Details: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        [.init(image: .ic16Tv, title: "Sample title", value: "Sample value")]
    }
}

// MARK: - Payment Requisites

extension OperationDetailDomain.State.Details: PaymentRequisitesProviding {
    
    var paymentRequisites: [DetailsCell] {
        [.init(image: .ic16Tv, title: "Sample title", value: "Sample value")]
    }
}

// MARK: - Short Transaction Details

extension OperationDetailDomain.State.EnhancedResponse: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        [.init(image: .ic16Tv, title: "Sample title", value: "Sample value")]
    }
}
