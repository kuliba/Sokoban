//
//  PaymentsTransfersSectionsViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import Foundation
import Combine

class PaymentsTransfersSectionViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
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

