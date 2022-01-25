//
//  ProductStatementData.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

struct ProductStatementData: Codable, Equatable {
    
    let MCC: Int?
    let accountID: Int?
    let accountNumber: String
    let amount: Double
    let cardTranNumber: String?
    let city: String?
    let comment: String
    let country: String?
    let currencyCodeNumeric: Int
    let date: Date
    let deviceCode: String?
    let documentAmount: Double?
    let documentID: Int?
    let fastPayment: FastPaymentData
    let groupName: String
    let isCancellation: Bool
    let md5hash: String
    let merchantName: String
    let merchantNameRus: String?
    let opCode: Int?
    let operationId: String?
    let operationType: OperationType
    let paymentDetailType: PaymentDetailType
    let svgImage: SVGImageData
    let terminalCode: String?
    let tranDate: Date
    let type: OperationEnvironment
}
