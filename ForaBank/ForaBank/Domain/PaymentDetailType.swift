//
//  PaymentDetailType.swift
//  ForaBank
//
//  Created by Max Gribov on 28.12.2021.
//

import Foundation

//[ BETWEEN_THEIR, CONTACT_ADDRESSLESS, DIRECT, EXTERNAL_ENTITY, EXTERNAL_INDIVIDUAL, HOUSING_AND_COMMUNAL_SERVICE, INSIDE_BANK, INSIDE_OTHER, INTERNET, MOBILE, NOT_FINANCE, OTHER_BANK, OUTSIDE_CASH, OUTSIDE_OTHER, SFP ]

enum PaymentDetailType: String, Codable {
    
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
}
