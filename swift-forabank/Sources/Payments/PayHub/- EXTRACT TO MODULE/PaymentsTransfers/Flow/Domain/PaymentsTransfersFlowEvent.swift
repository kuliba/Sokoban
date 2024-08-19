//
//  PaymentsTransfersFlowEvent.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public enum PaymentsTransfersFlowEvent<Profile, QR> {
    
    case open(Open)
    case profile(Profile)
    case qr(QR)
}

public extension PaymentsTransfersFlowEvent {
    
    enum Open {
        
        case profile, qr
    }
}

extension PaymentsTransfersFlowEvent: Equatable where Profile: Equatable, QR: Equatable {}
