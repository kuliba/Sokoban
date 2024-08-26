//
//  PaymentsTransfersToolbarEvent.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public enum PaymentsTransfersToolbarEvent: Equatable {
    
    case select(Select?)
}

public extension PaymentsTransfersToolbarEvent {
    
    enum Select {
        
        case profile, qr
    }
}
