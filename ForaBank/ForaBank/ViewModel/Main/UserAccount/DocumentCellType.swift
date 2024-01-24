//
//  DocumentCellType.swift
//  ForaBank
//
//  Created by Mikhail on 30.05.2022.
//

import Foundation
import SwiftUI

enum DocumentCellType {
    
    case passport
    case inn
    case adressPass
    case adress
}

extension DocumentCellType {
    
    var title: String {
        
        switch self {
            
        case .passport:     return "Паспорт"
        case .inn:          return "ИНН"
        case .adressPass:   return "Адрес регистрации"
        case .adress:       return "Адрес проживания"
        }
    }
    
    var icon: Image {
        
        switch self {
            
        case .passport:     return .ic24Passport
        case .inn:          return .ic24FileHash
        case .adressPass:   return .ic24Home
        case .adress:       return .ic24MapPin
        }
    }
    
    var iconBackground: Color {
        
        switch self {

        case .passport:     return .bgIconDeepPurpleMedium
        case .inn:          return .bgIconTealLight
        case .adressPass:   return .bgIconDeepPurpleMedium
        case .adress:       return .bgIconBlueLightest
        }
    }
    
    var backgroundColor: Color {
        
        switch self {
            
        case .passport:     return Color(hex: "8676A2")
        case .inn:          return Color(hex: "8676A2")
        case .adressPass:   return Color(hex: "8676A2")
        case .adress:       return Color(hex: "629FBB")
        }
    }
}
