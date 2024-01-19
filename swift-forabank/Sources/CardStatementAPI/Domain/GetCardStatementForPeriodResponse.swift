//
//  GetCardStatementForPeriodResponse.swift
//
//
//  Created by Andryusina Nataly on 18.01.2024.
//

import Foundation

public struct GetCardStatementForPeriodResponse: Codable, Equatable {
    
    public var id: Int { UUID().uuidString.hashValue }
    public let type: OperationEnvironment
    public let accountID: Int?
    public let operationType: OperationType
    public let paymentDetailType: Kind
    public let amount: Decimal?
    public let documentAmount: Decimal?
    public let comment: String
    public let documentID: Int?
    public let accountNumber: String
    public let currencyCodeNumeric: Int
    public let merchantName: String?
    public let merchantNameRus: String?
    public let groupName: String
    public let md5hash: String
    public let svgImage: String? // add svgKit
    public let fastPayment: FastPayment?
    public let terminalCode: String?
    public let deviceCode: String?
    public let country: String?
    public let city: String?
    public let operationId: String
    public let isCancellation: Bool?
    public let cardTranNumber: String?
    public let opCode: Int?
    public let date: Date
    public let tranDate: Date?
    public let MCC: Int?
    
    public init(
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
