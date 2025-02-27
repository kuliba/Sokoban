//
//  PromoProduct.swift
//  Vortex
//
//  Created by Andryusina Nataly on 22.01.2025.
//

import Foundation

enum PromoProduct: String {
    
    case creditCardMVP
    case sticker
    case savingsAccount
}

extension PromoProduct {
    
    var interfaceType: SettingType.Interface {
        switch self {
        case .creditCardMVP:    return .creditCardMVP
        case .sticker:          return .sticker
        case .savingsAccount:   return .savingsAccount
        }
    }
}
