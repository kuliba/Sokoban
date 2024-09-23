//
//  PaymentsTransfersToolbarFlowEffect.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public enum PaymentsTransfersToolbarFlowEffect: Equatable {
    
    case select(Select)
}

public extension PaymentsTransfersToolbarFlowEffect {
    
    enum Select {
        
        case profile, qr
    }
}
