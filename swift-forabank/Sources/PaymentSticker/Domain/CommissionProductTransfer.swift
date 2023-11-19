//
//  CommissionProductTransfer.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public enum CommissionProductTransferError: Error, Equatable {
    
    case error(
        statusCode: Int,
        errorMessage: String
    )
    case invalidData(statusCode: Int, data: Data)
}

public struct CommissionProductTransfer {
    
    let paymentOperationDetailId: Int
    let payerCardId: Int?
    let payerCardNumber: String?
    let payerAccountId: String?
    let payerAccountNumber: String?
    let payeeCardNumber: String?
    let payeeAccountNumber: String?
    let payeeName: String
    let amount: Decimal
    let debitAmount: Decimal
    let currencyAmount: String
    let currencyPayer: String
    let currencyPayee: String
    let currencyRate: String?
    let creditAmount: Decimal?
    let documentStatus: String?
}
