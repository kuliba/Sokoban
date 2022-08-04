//
//  ProductStatementMerchantGroup.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 02.08.2022.
//

import Foundation
import SwiftUI

enum ProductStatementMerchantGroup: String, Identifiable {
 
    case internalOperations = "Перевод внутри банка"
    case services = "Услуги"
    case others = "Прочие операции"
    case beauty = "Красота"
    case education = "Образование"
    case hobby = "Хобби и развлечения"
    case stateServices = "Оплата услуг/Налоги и госуслуги"
    case transport = "Транспорт"
    case communicationInternetTV = "Оплата услуг/Связь, интернет, ТВ"
    case aviaTickets = "Авиа билеты"
    case health = "Здоровье"
    case houseRenovation = "Дом, ремонт"
    case variousGoods = "Различные товары"
    case supermarket = "Супермаркет"
    case trainTickets = "Ж/д билеты"
    case restaurantsAndCafes = "Рестораны и кафе"
    case multimedia = "Мультимедиа"
    case restAndTravel = "Отдых и путешествия"
    case clothesAnAccessories = "Одежда и аксессуары"
    
    var id: String { self.rawValue }
    
    var color: Color {
        
        switch self {
        case .internalOperations: return .bGIconRedLight
        case .services: return .bGIconPurpleLight
        case .others: return .bGIconPinkLight
        case .beauty: return .bGIconPinkLightest
        case .education: return .bGIconDeepPurpleMedium
        case .hobby: return .bGIconDeepPurpleLight
        case .stateServices: return .bGIconIndigoLight
        case .transport: return .bGIconIndigoLightest
        case .communicationInternetTV: return .bGIconBlueLight
        case .aviaTickets: return .bGIconBlueLightest
        case .health: return .bGIconTealLight
        case .houseRenovation: return .bGIconGreenLight
        case .variousGoods: return .bGIconGreenLightest
        case .supermarket: return .bGIconLimeLight
        case .trainTickets: return .bGIconDeepOrangeLight
        case .restaurantsAndCafes: return .bGIconOrangeLight
        case .multimedia: return .bGIconOrangeLightest
        case .restAndTravel: return .bGIconAmberLight
        case .clothesAnAccessories: return .bGIconYellowLight
        }
    }
    
    init(_ rawString: String) {
        
        if let group = Self.init(rawValue: rawString) {
            self = group
        } else {
            self = .others
        }
    }
}
