//
//  BottomAmountEvent.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import Foundation

public enum BottomAmountEvent: Equatable {
    
    case edit(Decimal)
    case button(ButtonEvent)
    
    public enum ButtonEvent: Equatable {
        
        case setActive(Bool)
        case tap
    }
}
