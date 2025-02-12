//
//  FastOperations.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.02.2025.
//

import SwiftUI

enum FastOperations {
    
    case byQr, byPhone, templates, utility
    
    var title: String {
        
        switch self {
        case .byQr:      return FastOperationsTitles.qr
        case .byPhone:   return FastOperationsTitles.byPhone
        case .templates: return FastOperationsTitles.templates
        case .utility:   return FastOperationsTitles.utilityPayment
        }
    }
    
    var icon: Image {
        
        switch self {
        case .byQr:      return .ic24BarcodeScanner2
        case .byPhone:   return .ic24Smartphone
        case .templates: return .ic24Star
        case .utility:   return .ic24Bulb
        }
    }
}

enum FastOperationsTitles {
    
    static let qr = "Оплата по QR"
    static let byPhone = "Перевод по телефону"
    static let templates = "Шаблоны"
    static let utilityPayment = "Оплата ЖКУ"
}
