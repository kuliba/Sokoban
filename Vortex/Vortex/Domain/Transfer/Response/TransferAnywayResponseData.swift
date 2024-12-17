//
//  TransferAnywayResponseData.swift
//  ForaBank
//
//  Created by Max Gribov on 31.01.2022.
//

import Foundation

class TransferAnywayResponseData: TransferResponseData {

    let additionalList: [AdditionalData]
    let finalStep: Bool
    let infoMessage: String?
    let needSum: Bool
    let printFormType: String?
    let parameterListForNextStep: [ParameterData]
    
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
        additionalList: [AdditionalData],
        finalStep: Bool,
        infoMessage: String?,
        needSum: Bool,
        printFormType: String?,
        parameterListForNextStep: [ParameterData],
        scenario: AntiFraudScenario
    ) {
        
        self.additionalList = additionalList
        self.finalStep = finalStep
        self.infoMessage = infoMessage
        self.needSum = needSum
        self.printFormType = printFormType
        self.parameterListForNextStep = parameterListForNextStep
        
        super.init(amount: amount, creditAmount: creditAmount, currencyAmount: currencyAmount, currencyPayee: currencyPayee, currencyPayer: currencyPayer, currencyRate: currencyRate, debitAmount: debitAmount, fee: fee, needMake: needMake, needOTP: needOTP, payeeName: payeeName, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId, scenario: scenario)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case additionalList, finalStep, infoMessage, needSum, printFormType, parameterListForNextStep
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additionalList = try container.decode([AdditionalData].self, forKey: .additionalList)
        finalStep = try container.decode(Bool.self, forKey: .finalStep)
        infoMessage = try container.decodeIfPresent(String.self, forKey: .infoMessage)
        printFormType = try container.decodeIfPresent(String.self, forKey: .printFormType)
        needSum = try container.decode(Bool.self, forKey: .needSum)
        parameterListForNextStep = try container.decode([ParameterData].self, forKey: .parameterListForNextStep)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalList, forKey: .additionalList)
        try container.encode(finalStep, forKey: .finalStep)
        try container.encodeIfPresent(infoMessage, forKey: .infoMessage)
        try container.encode(needSum, forKey: .needSum)
        try container.encode(printFormType, forKey: .printFormType)
        try container.encode(parameterListForNextStep, forKey: .parameterListForNextStep)
        
        try super.encode(to: encoder)
    }
}

//MARK: - Types

extension TransferAnywayResponseData {
    
    struct AdditionalData: Codable, Equatable {
        
        let fieldName: String
        let fieldTitle: String?
        let fieldValue: String?
        let svgImage: SVGImageData?
        let typeIdParameterList: String?
        let recycle: Bool?
        
        var iconData: ImageData? {
            
            guard let svgImage = svgImage else {
                return nil
            }
            
            return ImageData(with: svgImage)
        }
    }
}

//MARK: - Equitable

extension TransferAnywayResponseData {
    
    static func == (lhs: TransferAnywayResponseData, rhs: TransferAnywayResponseData) -> Bool {
        
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
        lhs.paymentOperationDetailId == rhs.paymentOperationDetailId &&
        lhs.additionalList == rhs.additionalList &&
        lhs.finalStep == rhs.finalStep &&
        lhs.infoMessage == rhs.infoMessage &&
        lhs.needSum == rhs.needSum &&
        lhs.parameterListForNextStep == rhs.parameterListForNextStep
    }
}
