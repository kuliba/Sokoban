//
//  PaymentsTransfersSectionsViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import Foundation

class PaymentsTransfersSectionViewModel: ObservableObject, Identifiable {
    var id: String { type.rawValue }
    var title: String { type.name}
    var type: PaymentsTransfersSectionType { fatalError("init in subclass") }
}

enum PaymentsTransfersSectionType: String {
    case latestPayments
    case transfers
    case payGroup
    
    var name: String {
        switch self {
        case .latestPayments: return "Платежи"
        case .transfers: return "Перевести"
        case .payGroup: return "Оплатить"
        }
    }
}

