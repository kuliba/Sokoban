//
//  GKHDataCaseImage.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import Foundation

enum GKHDataCaseImage: String, CaseIterable {
    
    case personalAccount = "Лицевой счет"
    case counter         = "Счетчик"
    case address         = "Адрес"
    case paymentPeriod   = "Период оплаты"
    case insurance       = "Страхование"
    case phoneNumber     = "Номер телефона"
    case summ            = "Cумма (пени, задолженности)"
    case date            = "Дата"
    case transitonType   = "Тип перевода"
    case fio             = "ФИО"
    
    func returnStringImage() -> String {
        switch self {
        case .personalAccount:
            return "accaunt"
        case .counter:
            return "crosshair"
        case .address:
            return "map-pin"
        case .paymentPeriod:
            return "calendar"
        case .insurance:
            return "shield"
        case .phoneNumber:
            return "smartphone"
        case .summ:
            return "coins"
        case .date:
            return "date"
        case .transitonType:
            return "phone-forwarded"
        case .fio:
            return "fio"
        }
        
    }
}

