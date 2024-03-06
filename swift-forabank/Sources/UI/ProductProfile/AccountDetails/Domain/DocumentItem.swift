//
//  DocumentItem.swift
//  
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

struct DocumentItem {
    
    let id: ID
    
    enum ID {
        
        case accountNumber
        case bic
        case corrAccount
        case inn
        case kpp
        case payeeName
        case holderName
        case numberMasked
        case expirationDate
        case number
        case cvvMasked
        case cvv
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
        case .numberMasked, .number:
            return "Номер карты"
        case .holderName:
            return "Держатель карты"
        case .expirationDate:
            return "Карта действует до"
        case .cvvMasked, .cvv:
            return .cvvTitle
        }
    }
    
    var titleForInformer: String {
        switch id {
            
        case .expirationDate:
            return "Срок действия карты"
            
        default:
            return title
        }
    }
    
    let subtitle: String
    let valueForCopy: String
}

extension String {
    
    static let cvvTitle = "CVV"
}
