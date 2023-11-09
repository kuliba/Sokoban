//
//  CommissionProductTransfer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

struct CommissionProductTransferResponse: Decodable {
    
    let needMake: Bool
    let needOTP: Bool
    let amount: Double
    let creditAmount: Double?
    let fee: Double
    let currencyAmount: String
    let currencyPayer: String
    let currencyPayee: String
    let currencyRate: String?
    let debitAmount: Double
    let payeeName: String
    let paymentOperationDetailId: Int
    let documentStatus: String
}
