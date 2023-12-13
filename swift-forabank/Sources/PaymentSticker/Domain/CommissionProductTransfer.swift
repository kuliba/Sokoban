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
    
    public init(
        paymentOperationDetailId: Int,
        payerCardId: Int?,
        payerCardNumber: String?,
        payerAccountId: String?,
        payerAccountNumber: String?,
        payeeCardNumber: String?,
        payeeAccountNumber: String?,
        payeeName: String,
        amount: Decimal,
        debitAmount: Decimal,
        currencyAmount: String,
        currencyPayer: String,
        currencyPayee: String,
        currencyRate: String?,
        creditAmount: Decimal?,
        documentStatus: String?
    ) {
        self.paymentOperationDetailId = paymentOperationDetailId
        self.payerCardId = payerCardId
        self.payerCardNumber = payerCardNumber
        self.payerAccountId = payerAccountId
        self.payerAccountNumber = payerAccountNumber
        self.payeeCardNumber = payeeCardNumber
        self.payeeAccountNumber = payeeAccountNumber
        self.payeeName = payeeName
        self.amount = amount
        self.debitAmount = debitAmount
        self.currencyAmount = currencyAmount
        self.currencyPayer = currencyPayer
        self.currencyPayee = currencyPayee
        self.currencyRate = currencyRate
        self.creditAmount = creditAmount
        self.documentStatus = documentStatus
    }
}
