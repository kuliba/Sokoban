//
//  DocumentItem.swift
//  
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

public struct DocumentItem {
    
    let id: ID
    let subtitle: String
    let valueForCopy: String

    public init(
        id: ID,
        subtitle: String,
        valueForCopy: String
    ) {
        self.id = id
        self.subtitle = subtitle
        self.valueForCopy = valueForCopy
    }
    
    public enum ID: Hashable {
        
        case accountNumber
        case bic
        case corrAccount
        case inn
        case kpp
        case payeeName
        case holderName
        case expirationDate
        case number
        case cvv
        case info
    }
    
    var title: String {
        
        switch id {
            
        case .accountNumber:
            return "Номер счета"
        case .bic:
            return "БИК"
        case .corrAccount:
            return "Корреспондентский счет"
        case .inn:
            return "ИНН"
        case .kpp:
            return "КПП"
        case .payeeName:
            return "Получатель"
        case .number:
            return "Номер карты"
        case .holderName:
            return "Держатель карты"
        case .expirationDate:
            return "Карта действует до"
        case .cvv, .info:
            return .cvvTitle
        }
    }
}

extension String {
    
    static let cvvTitle = "CVV"
}
