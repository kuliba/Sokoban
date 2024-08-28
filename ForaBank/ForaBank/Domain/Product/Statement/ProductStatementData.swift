//
//  ProductStatementData.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

struct ProductStatementWithExtendedInfo: Codable, Equatable {

    let summary: ProductStatementSummary?
    let aggregated: [ProductStatementAggregated]?
    let operationList: [ProductStatementData]
    
    struct ProductStatementSummary: Codable, Equatable {
    
        let currencyCodeNumeric: String?
        let creditOperation: Bool?
        let debitOperation: Bool?
    }
    
    struct ProductStatementAggregated: Codable, Equatable {
        
        let groupByName: String?
        let baseColor: String?
        let debit: ProductStatementAmountAndPercent?
        let credit: ProductStatementAmountAndPercent?
    }
    
    struct ProductStatementAmountAndPercent: Codable, Equatable {
        
        let amount: Double?
        let amountPercent: Double?
    }
}

struct ProductStatementData: Identifiable, Equatable, Hashable {
    
    var id: String { operationId + operationType.rawValue }
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
    let isCancellation: Bool?
    let md5hash: String
    let merchantName: String?
    let merchantNameRus: String?
    let opCode: Int?
    let operationId: String
    let operationType: OperationType
    let paymentDetailType: Kind
    let svgImage: SVGImageData?
    let terminalCode: String?
    let tranDate: Date?
    let type: OperationEnvironment
    
    init(mcc: Int?, accountId: Int?, accountNumber: String, amount: Double, cardTranNumber: String?, city: String?, comment: String, country: String?, currencyCodeNumeric: Int, date: Date, deviceCode: String?, documentAmount: Double?, documentId: Int?, fastPayment: ProductStatementData.FastPayment?, groupName: String, isCancellation: Bool?, md5hash: String, merchantName: String?, merchantNameRus: String?, opCode: Int?, operationId: String, operationType: OperationType, paymentDetailType: ProductStatementData.Kind, svgImage: SVGImageData?, terminalCode: String?, tranDate: Date?, type: OperationEnvironment) {
        self.mcc = mcc
        self.accountId = accountId
        self.accountNumber = accountNumber
        self.amount = amount
        self.cardTranNumber = cardTranNumber
        self.city = city
        self.comment = comment
        self.country = country
        self.currencyCodeNumeric = currencyCodeNumeric
        self.date = date
        self.deviceCode = deviceCode
        self.documentAmount = documentAmount
        self.documentId = documentId
        self.fastPayment = fastPayment
        self.groupName = groupName
        self.isCancellation = isCancellation
        self.md5hash = md5hash
        self.merchantName = merchantName
        self.merchantNameRus = merchantNameRus
        self.opCode = opCode
        self.operationId = operationId
        self.operationType = operationType
        self.paymentDetailType = paymentDetailType
        self.svgImage = svgImage
        self.terminalCode = terminalCode
        self.tranDate = tranDate
        self.type = type
    }
}

extension ProductStatementData {
    
    struct FastPayment: Codable, Equatable, Hashable {
        
        let documentComment: String
        let foreignBankBIC: String
        let foreignBankID: String
        let foreignBankName: String
        let foreignName: String
        let foreignPhoneNumber: String
        let opkcid: String
        let operTypeFP: String
        let tradeName: String
        let guid: String
    }
    
    enum Kind: String, Codable, Hashable, Unknownable {
        
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
        case insideDeposit = "INSIDE_DEPOSIT"
        case sberQRPayment = "SBER_QR_PAYMENT"
        case networkMarketing = "NETWORK_MARKETING_SERVICE"
        case digitalWallet = "DIGITAL_WALLETS_SERVICE"
        case charity = "CHARITY_SERVICE"
        case socialAndGame = "SOCIAL_AND_GAMES_SERVICE"
        case education = "EDUCATION_SERVICE"
        case security = "SECURITY_SERVICE"
        case repayment = "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE"
        case unknown
    }
}

//MARK: - Codable

extension ProductStatementData: Codable {
    
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
        
        //FIXME: dirty hack for NOT_FINANCE paymentDetailType
        if let amount = try container.decodeIfPresent(Double.self, forKey: .amount) {
            
            self.amount = amount
            
        } else {
            
            self.amount = 0
        }
        
        self.cardTranNumber = try container.decodeIfPresent(String.self, forKey: .cardTranNumber)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.currencyCodeNumeric = try container.decode(Int.self, forKey: .currencyCodeNumeric)
        self.date = try container.decode(Date.self, forKey: .date)
        self.deviceCode = try container.decodeIfPresent(String.self, forKey: .deviceCode)
        self.documentAmount = try container.decodeIfPresent(Double.self, forKey: .documentAmount)
        self.documentId = try container.decodeIfPresent(Int.self, forKey: .documentId)
        self.groupName = try container.decode(String.self, forKey: .groupName)
        self.isCancellation = try container.decodeIfPresent(Bool.self, forKey: .isCancellation)
        self.md5hash = try container.decode(String.self, forKey: .md5hash)
        self.merchantName = try container.decodeIfPresent(String.self, forKey: .merchantName)
        self.merchantNameRus = try container.decodeIfPresent(String.self, forKey: .merchantNameRus)
        self.opCode = try container.decodeIfPresent(Int.self, forKey: .opCode)
        self.operationId = try container.decode(String.self, forKey: .operationId)
        self.terminalCode = try container.decodeIfPresent(String.self, forKey: .terminalCode)
        self.tranDate = try container.decodeIfPresent(Date.self, forKey: .tranDate)
        self.fastPayment = try container.decodeIfPresent(FastPayment.self, forKey: .fastPayment)
        self.operationType = try container.decode(OperationType.self, forKey: .operationType)
        self.paymentDetailType = try container.decode(ProductStatementData.Kind.self, forKey: .paymentDetailType)
        self.svgImage = try container.decodeIfPresent(SVGImageData.self, forKey: .svgImage)
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
        try container.encode(date.secondsSince1970UTC, forKey: .date)
        try container.encodeIfPresent(deviceCode, forKey: .deviceCode)
        try container.encodeIfPresent(documentAmount, forKey: .documentAmount)
        try container.encodeIfPresent(documentId, forKey: .documentId)
        try container.encodeIfPresent(fastPayment, forKey: .fastPayment)
        try container.encode(groupName, forKey: .groupName)
        try container.encodeIfPresent(isCancellation, forKey: .isCancellation)
        try container.encode(md5hash, forKey: .md5hash)
        try container.encodeIfPresent(merchantName, forKey: .merchantName)
        try container.encodeIfPresent(merchantNameRus, forKey: .merchantNameRus)
        try container.encodeIfPresent(opCode, forKey: .opCode)
        try container.encode(operationId, forKey: .operationId)
        try container.encode(operationType, forKey: .operationType)
        try container.encode(paymentDetailType, forKey: .paymentDetailType)
        try container.encodeIfPresent(svgImage, forKey: .svgImage)
        try container.encodeIfPresent(terminalCode, forKey: .terminalCode)
        
        if let tranDate = tranDate {
            
            try container.encode(tranDate.secondsSince1970UTC, forKey: .tranDate)
        }
        
        try container.encode(type, forKey: .type)
    }
}

//MARK: - Helpers

extension ProductStatementData {
    
    //TODO: ask business what merchant name placeholder should we use
    static let merchantNamePlaceholder = "--"
    
    var merchant: String { merchantNameRus ?? merchantName ?? Self.merchantNamePlaceholder }
    
    var isMinusSign: Bool {
        
        switch operationType {
        case .debit, .debitFict, .debitPlan: return true
        default: return false
        }
    }
    
    func operationSymbolsAndAmount(_ amountFormatted: String) -> String {
        
        switch operationType {
        case .debit, .debitPlan, .debitFict:
            return "- \(amountFormatted)"
            
        default:
            return "+ \(amountFormatted)"
        }
    }
    
    var isReturn: Bool {
        
        groupName.contains("Возврат")
    }
    
    var fastPaymentComment: String? {
        
        isReturn ? "Возврат по операции" : fastPayment?.documentComment
    }
    
    var dateValue: Date { tranDate ?? date }
    
    var isCreditType: Bool {
        
        [.credit, .creditFict, .creditPlan].contains(operationType)
    }
    
    var isDebitType: Bool {
        
        [.debit, .debitFict, .debitPlan].contains(operationType)
    }
    
    var shouldShowTemplateButton: Bool {
        
        ![.creditPlan, .debitFict, .creditFict].contains(operationType)
    }
    
    var shouldShowDocumentButton: Bool {
        
        ![.debitPlan, .creditPlan, .debitFict, .creditFict].contains(operationType)
    }
    
    func formattedAmountWithSign(_ formatAmount: String) -> String {
        
        isCreditType ? "+ \(formatAmount)" : formatAmount
    }
    
    func payeerTitle() -> String {
        
        isDebitType ? "Получатель" : "Отправитель"
    }
}
