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
    case updateInfo
    case latestPayments
    case transfers
    case payments
    
    var name: String {
        switch self {
        case .updateInfo: return ""
        case .latestPayments: return "Платежи"
        case .transfers: return "Перевести"
        case .payments: return "Оплатить"
        }
    }
}

