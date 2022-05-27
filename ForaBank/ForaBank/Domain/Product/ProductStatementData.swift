//
//  ProductStatementData.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

struct ProductStatementDataCacheble: Codable {
    
    var productStatement: [Int: [ProductStatementData]]
}

struct ProductStatementData: Codable, Equatable {
    
    let mcc: Int?
    let accountId: Int?
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
    let documentId: Int?
    let fastPayment: FastPayment?
    let groupName: String
    let isCancellation: Bool
    let md5hash: String
    let merchantName: String
    let merchantNameRus: String?
    let opCode: Int?
    let operationId: String?
    let operationType: OperationType
    let paymentDetailType: Kind
    let svgImage: SVGImageData
    let terminalCode: String?
    let tranDate: Date
    let type: OperationEnvironment
}

extension ProductStatementData {
    
    struct FastPayment: Codable, Equatable {
        
        let documentComment: String
        let foreignBankBIC: String
        let foreignBankID: String
        let foreignBankName: String
        let foreignName: String
        let foreignPhoneNumber: String
        let opkcid: String
    }
    
    enum Kind: String, Codable {
        
        case betweenTheir = "BETWEEN_THEIR"
        case contactAddressless = "CONTACT_ADDRESSLESS"
        case direct = "DIRECT"
        case externalEntity = "EXTERNAL_ENTITY"
        case externalIndivudual = "EXTERNAL_INDIVIDUAL"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case insideBank = "INSIDE_BANK"
        case insideOther = "INSIDE_OTHER"
        case internet = "INTERNET"
        case mobile = "MOBILE"
        case notFinance = "NOT_FINANCE"
        case otherBank = "OTHER_BANK"
        case outsideCash = "OUTSIDE_CASH"
        case outsideOther = "OUTSIDE_OTHER"
        case sfp = "SFP"
        case transport = "TRANSPORT"
        case taxes = "TAX_AND_STATE_SERVICE"
        case c2b = "C2B_PAYMENT"
    }
}

extension ProductStatementData {
    
    private enum CodingKeys: String, CodingKey {
        
        case mcc = "MCC"
        case accountId = "accountID"
        case documentId = "documentID"
        case accountNumber, amount, cardTranNumber, city, comment, country, currencyCodeNumeric, date, deviceCode, documentAmount, fastPayment, groupName, isCancellation, md5hash, merchantName, merchantNameRus, opCode, operationId, operationType, paymentDetailType, svgImage, terminalCode, tranDate, type
        
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mcc = try container.decodeIfPresent(Int.self, forKey: .mcc)
        self.accountId = try container.decodeIfPresent(Int.self, forKey: .accountId)
        self.accountNumber = try container.decode(String.self, forKey: .accountNumber)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.cardTranNumber = try container.decodeIfPresent(String.self, forKey: .cardTranNumber)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.currencyCodeNumeric = try container.decode(Int.self, forKey: .currencyCodeNumeric)
        let dateValue = try container.decode(Int.self, forKey: .date)
        self.date = Date(timeIntervalSince1970: TimeInterval(dateValue / 1000))
        self.deviceCode = try container.decodeIfPresent(String.self, forKey: .deviceCode)
        self.documentAmount = try container.decodeIfPresent(Double.self, forKey: .documentAmount)
        self.documentId = try container.decodeIfPresent(Int.self, forKey: .documentId)
        self.groupName = try container.decode(String.self, forKey: .groupName)
        self.isCancellation = try container.decode(Bool.self, forKey: .isCancellation)
        self.md5hash = try container.decode(String.self, forKey: .md5hash)
        self.merchantName = try container.decode(String.self, forKey: .merchantName)
        self.merchantNameRus = try container.decodeIfPresent(String.self, forKey: .merchantNameRus)
        self.opCode = try container.decodeIfPresent(Int.self, forKey: .opCode)
        self.operationId = try container.decodeIfPresent(String.self, forKey: .operationId)
        self.terminalCode = try container.decodeIfPresent(String.self, forKey: .terminalCode)
        let tranDateValue = try container.decode(Int.self, forKey: .tranDate)
        self.tranDate = Date(timeIntervalSince1970: TimeInterval(tranDateValue / 1000))
        self.fastPayment = try container.decodeIfPresent(FastPayment.self, forKey: .fastPayment)
        self.operationType = try container.decode(OperationType.self, forKey: .operationType)
        self.paymentDetailType = try container.decode(ProductStatementData.Kind.self, forKey: .paymentDetailType)
        self.svgImage = try container.decode(SVGImageData.self, forKey: .svgImage)
        self.type = try container.decode(OperationEnvironment.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mcc, forKey: .mcc)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encode(amount, forKey: .amount)
        try container.encode(cardTranNumber, forKey: .cardTranNumber)
        try container.encode(city, forKey: .city)
        try container.encode(comment, forKey: .comment)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encode(currencyCodeNumeric, forKey: .currencyCodeNumeric)
        try container.encode(Int(date.timeIntervalSince1970) * 1000, forKey: .date)
        try container.encodeIfPresent(deviceCode, forKey: .deviceCode)
        try container.encodeIfPresent(documentAmount, forKey: .documentAmount)
        try container.encodeIfPresent(documentId, forKey: .documentId)
        try container.encodeIfPresent(fastPayment, forKey: .fastPayment)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(isCancellation, forKey: .isCancellation)
        try container.encode(md5hash, forKey: .md5hash)
        try container.encode(merchantName, forKey: .merchantName)
        try container.encodeIfPresent(merchantNameRus, forKey: .merchantNameRus)
        try container.encodeIfPresent(opCode, forKey: .opCode)
        try container.encodeIfPresent(operationId, forKey: .operationId)
        try container.encode(operationType, forKey: .operationType)
        try container.encode(paymentDetailType, forKey: .paymentDetailType)
        try container.encode(svgImage, forKey: .svgImage)
        try container.encodeIfPresent(terminalCode, forKey: .terminalCode)
        try container.encode(Int(tranDate.timeIntervalSince1970) * 1000, forKey: .tranDate)
        try container.encode(type, forKey: .type)
    }
}

extension ProductStatementData {
    
    var amountFormattedtWithCurrency: String? {
        
        let currency = Model.shared.currency(for: currencyCodeNumeric)
        guard let currencyCode = currency?.code else { return nil }
        return self.amount.currencyFormatter(symbol: currencyCode)
    }
}
