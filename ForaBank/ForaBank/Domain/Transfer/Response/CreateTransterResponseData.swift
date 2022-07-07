//
//  CreateTransterResponseData.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 06.07.2022.
//

import Foundation

struct CreateTransferResponseData: Decodable, Equatable {
    
    let needMake: Bool?
    let needOTP: Bool?
    let amount: Double?
    let creditAmount: Double?
    let fee: Double?
    let currencyAmount: String?
    let currencyPayer: String?
    let currencyPayee: String?
    let currencyRate: Double?
    let debitAmount: Double?
    let payeeName: String?
    let paymentOperationDetailId: Int
    let documentStatus: TransferResponseBaseData.DocumentStatus
}
