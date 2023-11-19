//
//  CommissionProductTransfer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

struct CommissionProductTransfer {
    
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
