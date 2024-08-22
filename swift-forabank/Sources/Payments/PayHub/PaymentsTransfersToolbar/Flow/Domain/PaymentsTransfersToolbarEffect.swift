//
//  PaymentsTransfersToolbarEffect.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public enum PaymentsTransfersToolbarEffect: Equatable {
    
    case select(Select)
}

public extension PaymentsTransfersToolbarEffect {
    
    enum Select {
        
        case profile, qr
    }
}
