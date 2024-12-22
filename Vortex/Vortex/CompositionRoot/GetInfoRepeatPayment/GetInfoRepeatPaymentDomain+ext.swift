//
//  GetInfoRepeatPaymentDomain+ext.swift
//  Vortex
//
//  Created by Andryusina Nataly on 22.12.2024.
//

import Foundation
import GetInfoRepeatPaymentService
import RemoteServices

extension GetInfoRepeatPaymentDomain {
    
    typealias MappingError = RemoteServices.ResponseMapper.MappingError
    typealias Response = GetInfoRepeatPayment
    typealias Result = RemoteServices.ResponseMapper.MappingResult<Response>
    typealias Completion = (Result) -> Void
    
    enum _PaymentType {
        
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
}

extension String {
    
    var paymentType: GetInfoRepeatPaymentDomain._PaymentType? {
        
        switch camelCased {
        case "addressingCash", "addressless", "contactAddressless",
            "direct", "newDirect", "newDirectAccount", "newDirectCard",
            "foreignCard":
            return .direct
            
        case "betweenTheir":
            return .betweenTheir
            
        case "byPhone":
            return .byPhone
            
        case "charityService", "digitalWalletsService", "educationService", "housingAndCommunalService",
            "internet", "networkMarketingService","repaymentLoansAndAccountsService",
            "securityService", "socialAndGamesService", "transport":
            return .servicePayment
            
        case "externalEntity", "externalIndividual":
            return .repeatPaymentRequisites
            
        case "insideBank":
            return .insideBank
            
        case "mobile":
            return .mobile
            
        case "otherBank":
            return .otherBank

        case "sfp":
            return .sfp
            
        case "taxAndStateService":
            return .taxes
            
        default:
            return nil
        }
    }
}
