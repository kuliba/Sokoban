//
//  PaymentsTransfersToolbarState.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

struct PaymentsTransfersToolbarState<Profile, QR> {
    
    var navigation: Navigation?
}

extension PaymentsTransfersToolbarState {
    
    enum Navigation {
        
        case profile(Profile)
        case qr(QR)
    }
}

extension PaymentsTransfersToolbarState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersToolbarState.Navigation: Equatable where Profile: Equatable, QR: Equatable {}
