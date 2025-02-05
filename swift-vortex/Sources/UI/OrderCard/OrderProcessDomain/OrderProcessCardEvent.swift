//
//  OrderCardProcessEvent.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation
import AmountComponent

public enum OrderProcessCardEvent: Equatable {
    
    case dismiss
    case `continue`
    case amount(AmountEvent)
    case consent
}
