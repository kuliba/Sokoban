//
//  PaymentsTransfersToolbarEvent.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

enum PaymentsTransfersToolbarEvent<Profile, QR> {
    
    case dismiss
    case profile(Profile)
    case qr(QR)
    case select(Select)
}

extension PaymentsTransfersToolbarEvent: Equatable where Profile: Equatable, QR: Equatable {}

extension PaymentsTransfersToolbarEvent {
    
    enum Select {
        
        case profile, qr
    }
}
