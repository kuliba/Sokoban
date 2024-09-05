//
//  PaymentsTransfersPersonalToolbarEvent.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public enum PaymentsTransfersPersonalToolbarEvent: Equatable {
    
    case select(Select?)
}

public extension PaymentsTransfersPersonalToolbarEvent {
    
    enum Select {
        
        case profile, qr
    }
}
