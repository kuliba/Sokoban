//
//  OperationDetailsMapping.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import UIPrimitives

// MARK: - Transaction Details

extension OperationDetailDomain.State.Details: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] { [
        .field(.init(image: .ic16Tv, title: "Sample title", value: "Sample value"))
    ] }
}

// MARK: - Payment Requisites

extension OperationDetailDomain.State.Details: PaymentRequisitesProviding {
    
    var paymentRequisites: [DetailsCell.Field] { [
        .init(image: .ic16Tv, title: "Sample title", value: "Sample value")
    ] }
}

// MARK: - Short Transaction Details

extension OperationDetailDomain.State.EnhancedResponse: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        
        return [
            productCell,
            formattedAmountField.map(DetailsCell.field),
            formattedDateField.map(DetailsCell.field),
        ].compactMap { $0 }
    }
    
    private var productCell: DetailsCell {
        
        .product(.init(title: "Счет списания"))
    }
    
    private var formattedAmountField: DetailsCell.Field? {
        
        formattedAmount.map {
            
            .init(image: .ic24Coins, title: "Сумма платежа", value: $0)
        }
    }
    
    private var formattedDateField: DetailsCell.Field? {
        
        formattedDate.map {
            
            .init(image: .ic24Calendar, title: "Дата и время операции (МСК)", value: $0)
        }
    }
}
