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
    let parameterListForNextStep: [Parameter]
    
    internal init(amount: Double?, creditAmount: Double?, currencyAmount: String?, currencyPayee: String?, currencyPayer: String?, currencyRate: Double?, debitAmount: Double?,  fee: Double?, needMake: Bool?, needOTP: Bool?, payeeName: String?, documentStatus: DocumentStatus?, paymentOperationDetailId: Int, additionalList: [AdditionalData], finalStep: Bool, infoMessage: String?, needSum: Bool, parameterListForNextStep: [Parameter]) {
        
        self.additionalList = additionalList
        self.finalStep = finalStep
        self.infoMessage = infoMessage
        self.needSum = needSum
        self.parameterListForNextStep = parameterListForNextStep
        
        super.init(amount: amount, creditAmount: creditAmount, currencyAmount: currencyAmount, currencyPayee: currencyPayee, currencyPayer: currencyPayer, currencyRate: currencyRate, debitAmount: debitAmount, fee: fee, needMake: needMake, needOTP: needOTP, payeeName: payeeName, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case additionalList, finalStep, infoMessage, needSum, parameterListForNextStep
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additionalList = try container.decode([AdditionalData].self, forKey: .additionalList)
        finalStep = try container.decode(Bool.self, forKey: .finalStep)
        infoMessage = try container.decodeIfPresent(String.self, forKey: .infoMessage)
        needSum = try container.decode(Bool.self, forKey: .needSum)
        parameterListForNextStep = try container.decode([Parameter].self, forKey: .parameterListForNextStep)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalList, forKey: .additionalList)
        try container.encode(finalStep, forKey: .finalStep)
        try container.encodeIfPresent(infoMessage, forKey: .infoMessage)
        try container.encode(needSum, forKey: .needSum)
        try container.encode(parameterListForNextStep, forKey: .parameterListForNextStep)
        
        try super.encode(to: encoder)
    }
}

//MARK: - Types

extension TransferAnywayResponseData {
    
    struct AdditionalData: Codable, Equatable {
        
        let fieldName: String
        let fieldTitle: String
        let fieldValue: String
        let svgImage: SVGImageData?
    }
    
    struct Parameter: Codable, Equatable {
        
        let content: String?
        let dataType: String
        let id: String
        let isPrint: Bool?
        let isRequired: Bool
        let mask: String
        let maxLength: Int?
        let minLength: Int?
        let order: Int?
        let rawLength: Int
        let readOnly: Bool
        let regExp: String
        let subTitle: String?
        let svgImage: SVGImageData?
        let title: String
        let type: String //FIXME: enum?
        let viewType: ViewType
        
        enum ViewType: String, Codable, Equatable {
            
            case constant = "CONSTANT"
            case input = "INPUT"
            case optput = "OUTPUT"
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
