//
//  PaymentsTransfersToolbarFlowEvent.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public enum PaymentsTransfersToolbarFlowEvent<Profile, QR> {
    
    case dismiss
    case profile(Profile)
    case qr(QR)
    case select(Select)
}

public extension PaymentsTransfersToolbarFlowEvent {
    
    enum Select {
        
        case profile, qr
    }
}

extension PaymentsTransfersToolbarFlowEvent: Equatable where Profile: Equatable, QR: Equatable {}
