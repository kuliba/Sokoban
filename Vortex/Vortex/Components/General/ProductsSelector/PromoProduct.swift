//
//  PromoProduct.swift
//  Vortex
//
//  Created by Andryusina Nataly on 22.01.2025.
//

import Foundation

enum PromoProduct: String {

    case sticker
    case savingsAccount
    case collateralLoan
    case collateralLoanCar
    case collateralLoanRealEstate
}

extension PromoProduct {
    
    var interfaceType: SettingType.Interface {
        switch self {
        case .sticker:                  return .sticker
        case .savingsAccount:           return .savingsAccount
        case .collateralLoan:           return .collateralLoan
        case .collateralLoanCar:        return .collateralLoanCar
        case .collateralLoanRealEstate: return .collateralLoanRealEstate
        }
    }
}

enum CollateralLoanType: String {
    
    case showcase
    case car = "Кредит под залог транспорта"
    case realEstate = "Кредит под залог недвижимости"
    
    var id: String {
        
        switch self {
            
        case .showcase:
            return ""
            
        case .car:
            return "CAR_LANDING"
        
        case .realEstate:
            return "REAL_ESTATE_LANDING"
        }
    }
}

extension PromoProduct {
    
    static func collateralLoanTypeMap(from productName: String) -> Self {
        
        switch CollateralLoanType(rawValue: productName) {
            
        case .car:
            return .collateralLoanCar

        case .realEstate:
            return .collateralLoanRealEstate

        default:
            return .collateralLoan
        }
    }
}
