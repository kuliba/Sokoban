//
//  PaymentType.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.12.2024.
//

enum PaymentType {
    
    case betweenTheir
    case byPhone
    case direct
    case insideBank
    case mobile
    case otherBank
    case repeatPaymentRequisites
    case servicePayment
    case sfp
    case taxes
}

extension PaymentType {
    
    init?(_ string: String) {
        
        switch string.camelCased {
        case "addressingCash", "addressless", "contactAddressless",
            "direct", "newDirect", "newDirectAccount", "newDirectCard",
            "foreignCard":
            self = .direct
            
        case "betweenTheir":
            self = .betweenTheir
            
        case "byPhone":
            self = .byPhone
            
        case "charityService", "digitalWalletsService", "educationService", "housingAndCommunalService",
            "internet", "networkMarketingService","repaymentLoansAndAccountsService",
            "securityService", "socialAndGamesService", "transport":
            self = .servicePayment
            
        case "externalEntity", "externalIndividual":
            self = .repeatPaymentRequisites
            
        case "insideBank":
            self = .insideBank
            
        case "mobile":
            self = .mobile
            
        case "otherBank":
            self = .otherBank

        case "sfp":
            self = .sfp
            
        case "taxAndStateService":
            self = .taxes
            
        default:
            return nil
        }
    }
}
