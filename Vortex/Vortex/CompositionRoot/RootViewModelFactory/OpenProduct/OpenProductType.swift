//
//  OpenProductType.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import SwiftUI

enum OpenProductType: Equatable, CaseIterable, Hashable {
    
    case account
    case card
    case creditCardMVP
    case deposit
    case insurance
    case loan
    case mortgage
    case savingsAccount
    case sticker
}

// TODO: move to view

extension OpenProductType {
    
    var openButtonIcon: Image {
        
        switch self {
        case .account:          return .ic24FilePluseColor
        case .card:             return .ic24NewCardColor
        case .creditCardMVP:    return .ic24NewCardColor
        case .deposit:          return .ic24DepositPlusColor
        case .insurance:        return .ic24InsuranceColor
        case .loan:             return .ic24CreditColor
        case .mortgage:         return .ic24Mortgage
        case .savingsAccount:   return .ic24FilePluseColorProcent
        case .sticker:          return .ic24Sticker
        }
    }
    
    var openButtonTitle: String {
        
        switch self {
        case .account:          return "Счет"
        case .card:             return "Карту"
        case .creditCardMVP:    return "Кредитную карту"
        case .deposit:          return "Вклад"
        case .insurance:        return "Страховку"
        case .loan:             return "Кредит"
        case .mortgage:         return "Ипотеку"
        case .savingsAccount:   return "Счет накопительный"
        case .sticker:          return "Стикер"
        }
    }
}
