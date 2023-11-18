//
//  CommissionProductTransfer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

struct CommissionProductTransferResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: Data

    struct Data: Decodable {
        
        let paymentOperationDetailId: Int
        let payerCardId: Int?
        let payerCardNumber: String?
        let payerAccountId: String?
        let payerAccountNumber: String?
        let payeeCardNumber: String?
        let payeeAccountNumber: String?
        let payeeName: String
        let amount: Double
        let debitAmount: Double
        let currencyAmount: String
        let currencyPayer: String
        let currencyPayee: String
        let currencyRate: String?
        let creditAmount: Double?
        let documentStatus: String?
    }
}
