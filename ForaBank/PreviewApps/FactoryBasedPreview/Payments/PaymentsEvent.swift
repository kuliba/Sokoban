//
//  PaymentsEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

enum PaymentsEvent {
    
    case buttonTapped(ButtonTapped)
}

extension PaymentsEvent {
    
    enum ButtonTapped {
        
        case utilityService
    }
}
