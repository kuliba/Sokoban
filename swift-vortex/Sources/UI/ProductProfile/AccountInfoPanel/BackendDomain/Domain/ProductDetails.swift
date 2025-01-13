//
//  ProductDetails.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

public enum ProductDetails: Equatable {
    
    case accountDetails(AccountDetails)
    case cardDetails(CardDetails)
    case depositDetails(DepositDetails)
}

public extension ProductDetails {
    
    var payeeName: String {
        
        switch self {
        case let .accountDetails(details):
            return details.payeeName
        case let .cardDetails(details):
            return details.payeeName
        case let .depositDetails(details):
            return details.payeeName
        }
    }
    
    var accountNumber: String {
        
        switch self {
        case let .accountDetails(details):
            return details.accountNumber
        case let .cardDetails(details):
            return details.accountNumber
        case let .depositDetails(details):
            return details.accountNumber
        }
    }

    var bic: String {
        
        switch self {
        case let .accountDetails(details):
            return details.bic
        case let .cardDetails(details):
            return details.bic
        case let .depositDetails(details):
            return details.bic
        }
    }

    var corrAccount: String {
        
        switch self {
        case let .accountDetails(details):
            return details.corrAccount
        case let .cardDetails(details):
            return details.corrAccount
        case let .depositDetails(details):
            return details.corrAccount
        }
    }
    
    var inn: String {
        
        switch self {
        case let .accountDetails(details):
            return details.inn
        case let .cardDetails(details):
            return details.inn
        case let .depositDetails(details):
            return details.inn
        }
    }

    var kpp: String {
        
        switch self {
        case let .accountDetails(details):
            return details.kpp
        case let .cardDetails(details):
            return details.kpp
        case let .depositDetails(details):
            return details.kpp
        }
    }
    
    var info: String {
        
        switch self {
        case let .cardDetails(details):
            return details.info
        default:
            return ""
        }
    }

    var infoMd5hash: String {
        
        switch self {
        case let .cardDetails(details):
            return details.md5hash
        default:
            return ""
        }
    }
}
