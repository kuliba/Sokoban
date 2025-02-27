//
//  ProductStatementData.swift
//  
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

public struct ProductStatementWithExtendedInfo: Equatable {

    public let summary: ProductStatementSummary?
    public let aggregated: [ProductStatementAggregated]?
    public let operationList: [ProductStatementData]
    
    public init(
        summary: ProductStatementWithExtendedInfo.ProductStatementSummary? = nil,
        aggregated: [ProductStatementWithExtendedInfo.ProductStatementAggregated]? = nil,
        operationList: [ProductStatementData]
    ) {
        self.summary = summary
        self.aggregated = aggregated
        self.operationList = operationList
    }
}

public extension ProductStatementWithExtendedInfo {
    
    struct ProductStatementAmountAndPercent: Equatable {
        
        let amount: Double?
        let amountPercent: Double?
        
        public init(
            amount: Double?,
            amountPercent: Double?
        ) {
            self.amount = amount
            self.amountPercent = amountPercent
        }
    }
}

public extension ProductStatementWithExtendedInfo {

    struct ProductStatementAggregated: Equatable {
        
        let groupByName: String?
        let baseColor: String?
        let debit: ProductStatementAmountAndPercent?
        let credit: ProductStatementAmountAndPercent?
        
        public init(
            groupByName: String? = nil,
            baseColor: String? = nil,
            debit: ProductStatementWithExtendedInfo.ProductStatementAmountAndPercent? = nil,
            credit: ProductStatementWithExtendedInfo.ProductStatementAmountAndPercent? = nil
        ) {
            self.groupByName = groupByName
            self.baseColor = baseColor
            self.debit = debit
            self.credit = credit
        }
    }
}

public extension ProductStatementWithExtendedInfo {
    
    struct ProductStatementSummary: Equatable {
    
        let currencyCodeNumeric: String?
        let creditOperation: Bool?
        let debitOperation: Bool?
        
        internal init(
            currencyCodeNumeric: String? = nil,
            creditOperation: Bool? = nil,
            debitOperation: Bool? = nil
        ) {
            self.currencyCodeNumeric = currencyCodeNumeric
            self.creditOperation = creditOperation
            self.debitOperation = debitOperation
        }
    }
}

public struct ProductStatementData: Equatable {
    
    public let type: OperationEnvironment
    public let accountID: Int?
    public let operationType: OperationType
    public let paymentDetailType: Kind
    public let amount: Decimal
    public let documentAmount: Decimal
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
    
    // V3
    public let discount: String?
    public let transAmm: String?
    public let discountExpiry: String?
    public let dateN: String?
    public let paymentTerm: String?
    public let legalAct: String?
    public let supplierBillId: String?
    public let realPayerFIO: String?
    public let realPayerINN: String?
    public let realPayerKPP: String?
    public let upno: String?
    
    public init(
        type: OperationEnvironment,
        accountID: Int?,
        operationType: OperationType,
        paymentDetailType: Kind,
        amount: Decimal,
        documentAmount: Decimal,
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
        MCC: Int?,
        discount: String?,
        transAmm: String?,
        discountExpiry: String?,
        dateN: String?,
        paymentTerm: String?,
        legalAct: String?,
        supplierBillId: String?,
        realPayerFIO: String?,
        realPayerINN: String?,
        realPayerKPP: String?,
        upno: String?
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
        self.discount = discount
        self.transAmm = transAmm
        self.discountExpiry = discountExpiry
        self.dateN = dateN
        self.paymentTerm = paymentTerm
        self.legalAct = legalAct
        self.supplierBillId = supplierBillId
        self.realPayerFIO = realPayerFIO
        self.realPayerINN = realPayerINN
        self.realPayerKPP = realPayerKPP
        self.upno = upno
    }
}
