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
}

enum _PaymentType {
    
    case byPhone
    case direct
    case insideBank
    case betweenTheir
    case mobile
    case otherBank
    case repeatPaymentRequisites
    case servicePayment
    case sfp
    case taxes
    case unknown
}

extension String {
    
    var paymentType: _PaymentType {
        
        switch camelCased {
        case "betweenTheir":
            return .betweenTheir
            
        case "addressingCash", "addressless", "contactAddressless", "direct", "newDirect", "newDirectAccount", "newDirectCard", "foreignCard":
            return .direct
            
        case "externalEntity", "externalIndividual":
            return .repeatPaymentRequisites
            
        case "insideBank":
            return .insideBank
            
        case "otherBank":
            return .otherBank
           
        case "internet", "transport", "housingAndCommunalService", "charityService", "digitalWalletsService", "educationService", "networkMarketingService", "repaymentLoansAndAccountsService", "securityService", "socialAndGamesService":
            return .servicePayment
        
        case "byPhone":
            return .byPhone
            
        case "sfp":
            return .sfp
            
        case "mobile":
            return .mobile
            
        case "taxAndStateService":
            return .taxes
         
        default:
            return .unknown
        }
    }
}
