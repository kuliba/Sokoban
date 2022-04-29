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
    let fastPayment: FastPayment
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
        let operTypeFP: String?
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
