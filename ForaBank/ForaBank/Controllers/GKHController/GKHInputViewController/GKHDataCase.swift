//
//  GKHDataCase.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import Foundation

enum GKHDataCase: CaseIterable {
    
    case personalAccount
    case counter
    case address
    case paymentPeriod
    case insurance
    case phoneNumber
    case summ
    case date
    case transitonType
    case fio
    
    func returnDataCase() -> [String: [String]] {
        switch self {
        case .personalAccount:
            return GKHDataType.personalAccount
        case .counter:
            return GKHDataType.counter
        case .address:
            return GKHDataType.address
        case .paymentPeriod:
            return GKHDataType.paymentPeriod
        case .insurance:
            return GKHDataType.insurance
        case .phoneNumber:
            return GKHDataType.phoneNumber
        case .summ:
            return GKHDataType.summ
        case .date:
            return GKHDataType.date
        case .transitonType:
            return GKHDataType.transitonType
        case .fio:
            return GKHDataType.fio
        }
        
    }
}
