//
//  GetCardStatementForPeriodResponse.swift
//
//
//  Created by Andryusina Nataly on 18.01.2024.
//

import Foundation

struct GetCardStatementForPeriodResponse: Codable {
    
    var id: Int = UUID().uuidString.hashValue
    let type: OperationEnvironment
    let accountID: Int64?
    let operationType: OperationType
    let paymentDetailType: Kind
    let amount: Decimal?
    let documentAmount: Decimal?
    let comment: String
    let documentID: Int64?
    let accountNumber: String
    let currencyCodeNumeric: Int32
    let merchantName: String?
    let merchantNameRus: String?
    let groupName: String
    let md5hash: String
    let svgImage: String? // add svgKit
    let fastPayment: FastPayment?
    let terminalCode: String?
    let deviceCode: String?
    let country: String?
    let city: String?
    let operationId: String
    let isCancellation: Bool?
    let cardTranNumber: String?
    let opCode: Int64?
    let date: Date
    let tranDate: Date?
    let MCC: Int32?
}
