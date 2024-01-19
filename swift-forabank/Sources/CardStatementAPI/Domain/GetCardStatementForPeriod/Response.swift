//
//  Response.swift
//
//
//  Created by Andryusina Nataly on 18.01.2024.
//

import Foundation

struct Response: Decodable, Equatable {
    
    let type: OperationEnvironment
    let accountID: Int?
    let operationType: OperationType
    let paymentDetailType: Kind
    let amount: Decimal?
    let documentAmount: Decimal?
    let comment: String
    let documentID: Int?
    let accountNumber: String
    let currencyCodeNumeric: Int
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
    let opCode: Int?
    let date: Date
    let tranDate: Date?
    let MCC: Int?
    
    init(
        type: OperationEnvironment,
        accountID: Int?,
        operationType: OperationType,
        paymentDetailType: Kind,
        amount: Decimal?,
        documentAmount: Decimal?,
        comment: String,
        documentID: Int?,
        accountNumber: String,
        currencyCodeNumeric: Int,
        merchantName: String?,
        merchantNameRus: String?,
        groupName: String,
        md5hash: String,
        svgImage: String?,
        fastPayment: FastPayment?,
        terminalCode: String?,
        deviceCode: String?,
        country: String?,
        city: String?,
        operationId: String,
        isCancellation: Bool?,
        cardTranNumber: String?,
        opCode: Int?,
        date: Date,
        tranDate: Date?,
        MCC: Int?
    ) {
        self.type = type
        self.accountID = accountID
        self.operationType = operationType
        self.paymentDetailType = paymentDetailType
        self.amount = amount
        self.documentAmount = documentAmount
        self.comment = comment
        self.documentID = documentID
        self.accountNumber = accountNumber
        self.currencyCodeNumeric = currencyCodeNumeric
        self.merchantName = merchantName
        self.merchantNameRus = merchantNameRus
        self.groupName = groupName
        self.md5hash = md5hash
        self.svgImage = svgImage
        self.fastPayment = fastPayment
        self.terminalCode = terminalCode
        self.deviceCode = deviceCode
        self.country = country
        self.city = city
        self.operationId = operationId
        self.isCancellation = isCancellation
        self.cardTranNumber = cardTranNumber
        self.opCode = opCode
        self.date = date
        self.tranDate = tranDate
        self.MCC = MCC
    }
}

extension Response {
    
    var amountValue: Decimal { amount ?? 0 }
    var documentAmountValue:  Decimal { documentAmount ?? 0 }
}
