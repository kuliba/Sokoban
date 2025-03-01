//
//  FastOperations.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.02.2025.
//

import SwiftUI

enum FastOperations {
    
    case byPhone, byQR, templates, uin, utility
    
    var title: String {
        
        switch self {
        case .byQR:      return FastOperationsTitles.qr
        case .byPhone:   return FastOperationsTitles.byPhone
        case .templates: return FastOperationsTitles.templates
        case .uin:       return FastOperationsTitles.uin
        case .utility:   return FastOperationsTitles.utilityPayment
        }
    }
}

enum FastOperationsTitles {
    
    static let qr             = "Оплата по QR"
    static let byPhone        = "Перевод по телефону"
    static let templates      = "Шаблоны"
    static let uin            = "Поиск по УИН"
    static let utilityPayment = "Оплата ЖКУ"
}
