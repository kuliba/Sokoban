//
//  Response+Kind.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension Response {
    
    enum Kind: String, Decodable {
        
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
    }
}

extension Response.Kind {
    
    var value: ProductStatementData.Kind {
        
        switch self {
            
        case .betweenTheir:
            return .betweenTheir
        case .contactAddressless:
            return .contactAddressless
        case .direct:
            return .direct
        case .externalEntity:
            return .externalEntity
        case .externalIndivudual:
            return .externalIndivudual
        case .housingAndCommunalService:
            return .housingAndCommunalService
        case .insideBank:
            return .insideBank
        case .insideOther:
            return .insideOther
        case .internet:
            return .internet
        case .mobile:
            return .mobile
        case .notFinance:
            return .notFinance
        case .otherBank:
            return .otherBank
        case .outsideCash:
            return .outsideCash
        case .outsideOther:
            return .outsideOther
        case .sfp:
            return .sfp
        case .transport:
            return .transport
        case .taxes:
            return .taxes
        case .c2b:
            return .c2b
        case .insideDeposit:
            return .insideDeposit
        case .sberQRPayment:
            return .sberQRPayment
        }
    }
}

