//
//  ProductStatementMerchantGroup.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 02.08.2022.
//

import Foundation
import SwiftUI

enum ProductStatementMerchantGroup: String, Identifiable, CaseIterable, Equatable {
 
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
        case .internalOperations: return .bgIconRedLight
        case .services: return .bgIconPurpleLight
        case .others: return .bgIconPinkLight
        case .beauty: return .bgIconPinkLightest
        case .education: return .bgIconDeepPurpleMedium
        case .hobby: return .bgIconDeepPurpleLight
        case .stateServices: return .bgIconIndigoLight
        case .transport: return .bgIconIndigoLightest
        case .communicationInternetTV: return .bgIconBlueLight
        case .aviaTickets: return .bgIconBlueLightest
        case .health: return .bgIconTealLight
        case .houseRenovation: return .bgIconGreenLight
        case .variousGoods: return .bgIconGreenLightest
        case .supermarket: return .bgIconLimeLight
        case .trainTickets: return .bgIconDeepOrangeLight
        case .restaurantsAndCafes: return .bgIconOrangeLight
        case .multimedia: return .bgIconOrangeLightest
        case .restAndTravel: return .bgIconAmberLight
        case .clothesAnAccessories: return .bgIconYellowLight
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
