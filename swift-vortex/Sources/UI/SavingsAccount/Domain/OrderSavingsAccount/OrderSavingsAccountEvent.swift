//
//  OrderSavingsAccountEvent.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation
import AmountComponent

public enum OrderSavingsAccountEvent: Equatable {
    
    case dismiss
    case `continue`
    case amount(AmountEvent)
    case consent
}
