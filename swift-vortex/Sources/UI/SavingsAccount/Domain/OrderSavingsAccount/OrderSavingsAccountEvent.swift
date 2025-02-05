//
//  OrderSavingsAccountEvent.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation
import AmountComponent

public enum OrderSavingsAccountEvent: Equatable {
    
    case amount(AmountEvent)
    case consent
    case `continue`
    case dismiss
    case openURL(URL)
}
