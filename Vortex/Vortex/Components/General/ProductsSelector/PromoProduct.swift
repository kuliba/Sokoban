//
//  PromoProduct.swift
//  Vortex
//
//  Created by Andryusina Nataly on 22.01.2025.
//

import Foundation

enum PromoProduct: Equatable {
    
    case creditCardMVP
    case sticker
    case savingsAccount
    case collateralLoan(CollateralLoanType)
}

extension PromoProduct {
    
    var interfaceType: SettingType.Interface {
        switch self {
        case .creditCardMVP:            return .creditCardMVP
        case .sticker:                  return .sticker
        case .savingsAccount:           return .savingsAccount
        case let .collateralLoan(type): return .collateralLoan(type)
        }
    }
}

enum CollateralLoanType {
    
    case showcase
    case car
    case realEstate
    
    init(rawValue: String) {
        
        switch rawValue {
        case .carLanding:
            self = .car
            
        case .realEstateLanding:
            self = .realEstate

        default:
            self = .showcase
        }
    }
    
    var id: String {
        
        switch self {
            
        case .showcase:
            return .showcase
            
        case .car:
            return .carLanding
        
        case .realEstate:
            return .realEstateLanding
        }
    }
}

private extension String {
    
    static let sticker = "sticker"
    static let savingsAccount = "savingsAccount"
    static let collateralLoanShowcase = "collateralLoanShowcase"
    static let collateralLoanCar = "collateralLoanCar"
    static let collateralLoanRealEstate = "collateralLoanRealEstate"
    static let creditCardMVP = "creditCardMVP"
}
