//
//  TransferResponseData.swift
//  ForaBank
//
//  Created by Max Gribov on 31.01.2022.
//

import Foundation

class TransferResponseData: TransferResponseBaseData {

    let amount: Double?
    let creditAmount: Double?
    let currencyAmount: Currency?
    let currencyPayee: Currency?
    let currencyPayer: Currency?
    let currencyRate: Double?
    let debitAmount: Double?
    let fee: Double?
    let needMake: Bool?
    let needOTP: Bool?
    let payeeName: String?
    let scenario: AntiFraudScenario?

    internal init(
        amount: Double?,
        creditAmount: Double?,
        currencyAmount: Currency?,
        currencyPayee: Currency?,
        currencyPayer: Currency?,
        currencyRate: Double?,
        debitAmount: Double?,
        fee: Double?,
        needMake: Bool?,
        needOTP: Bool?,
        payeeName: String?,
        documentStatus: DocumentStatus?,
        paymentOperationDetailId: Int,
        scenario: AntiFraudScenario?
    ) {
        
        self.amount = amount
        self.creditAmount = creditAmount
        self.currencyAmount = currencyAmount
        self.currencyPayee = currencyPayee
        self.currencyPayer = currencyPayer
        self.currencyRate = currencyRate
        self.debitAmount = debitAmount
        self.fee = fee
        self.needMake = needMake
        self.needOTP = needOTP
        self.payeeName = payeeName
        self.scenario = scenario
        
        super.init(documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case amount, creditAmount, currencyAmount, currencyPayee, currencyPayer, currencyRate, debitAmount, documentStatus, fee, needMake, needOTP, payeeName, paymentOperationDetailId, scenario
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        creditAmount = try container.decodeIfPresent(Double.self, forKey: .creditAmount)
        currencyAmount = try container.decodeIfPresent(Currency.self, forKey: .currencyAmount)
        currencyPayee = try container.decodeIfPresent(Currency.self, forKey: .currencyPayee)
        currencyPayer = try container.decodeIfPresent(Currency.self, forKey: .currencyPayer)
        currencyRate = try container.decodeIfPresent(Double.self, forKey: .currencyRate)
        debitAmount = try container.decodeIfPresent(Double.self, forKey: .debitAmount)
        fee = try container.decodeIfPresent(Double.self, forKey: .fee)
        needMake = try container.decodeIfPresent(Bool.self, forKey: .needMake)
        needOTP = try container.decodeIfPresent(Bool.self, forKey: .needOTP)
        payeeName = try container.decodeIfPresent(String.self, forKey: .payeeName)
        scenario = try container.decodeIfPresent(AntiFraudScenario.self, forKey: .scenario)
       
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(creditAmount, forKey: .creditAmount)
        try container.encodeIfPresent(currencyAmount, forKey: .currencyAmount)
        try container.encodeIfPresent(currencyPayee, forKey: .currencyPayee)
        try container.encodeIfPresent(currencyPayer, forKey: .currencyPayer)
        try container.encodeIfPresent(currencyRate, forKey: .currencyRate)
        try container.encodeIfPresent(debitAmount, forKey: .debitAmount)
        try container.encodeIfPresent(fee, forKey: .fee)
        try container.encodeIfPresent(needMake, forKey: .needMake)
        try container.encodeIfPresent(needOTP, forKey: .needOTP)
        try container.encodeIfPresent(payeeName, forKey: .payeeName)
        try container.encodeIfPresent(scenario, forKey: .scenario)
        
        try super.encode(to: encoder)
    }
}

//MARK: - Equitable

extension TransferResponseData {
    
    static func == (lhs: TransferResponseData, rhs: TransferResponseData) -> Bool {
        
        return  lhs.amount == rhs.amount &&
        lhs.creditAmount == rhs.creditAmount &&
        lhs.currencyAmount == rhs.currencyAmount &&
        lhs.currencyPayee == rhs.currencyPayee &&
        lhs.currencyPayer == rhs.currencyPayer &&
        lhs.currencyRate == rhs.currencyRate &&
        lhs.debitAmount == rhs.debitAmount &&
        lhs.fee == rhs.fee &&
        lhs.needMake == rhs.needMake &&
        lhs.needOTP == rhs.needOTP &&
        lhs.payeeName == rhs.payeeName &&
        lhs.documentStatus == rhs.documentStatus &&
        lhs.paymentOperationDetailId == rhs.paymentOperationDetailId
    }
}

extension TransferResponseData {

    func update(_ transferData: TransferResponseData, transferBaseData: TransferResponseBaseData) -> TransferResponseData {
        
        .init(
            amount: transferData.amount,
            creditAmount: transferData.creditAmount,
            currencyAmount: transferData.currencyAmount,
            currencyPayee: transferData.currencyPayee,
            currencyPayer: transferData.currencyPayer,
            currencyRate: transferData.currencyRate,
            debitAmount: transferData.debitAmount,
            fee: transferData.fee,
            needMake: transferData.needMake,
            needOTP: transferData.needOTP,
            payeeName: transferData.payeeName,
            documentStatus: transferBaseData.documentStatus,
            paymentOperationDetailId: transferBaseData.paymentOperationDetailId,
            scenario: .ok
        )
    }
}

extension TransferResponseData {
    
    enum AntiFraudScenario: String, Codable {
        
        case suspect = "SCOR_SUSPECT_FRAUD"
        case ok = "OK"
    }
}
