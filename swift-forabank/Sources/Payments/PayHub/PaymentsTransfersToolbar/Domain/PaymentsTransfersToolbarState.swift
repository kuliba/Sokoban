//
//  PaymentsTransfersToolbarState.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public struct PaymentsTransfersToolbarState<Profile, QR> {
    
    public var navigation: Navigation?
    
    public init(
        navigation: Navigation? = nil
    ) {
        self.navigation = navigation
    }
}

public extension PaymentsTransfersToolbarState {
    
    enum Navigation {
        
        case profile(Profile)
        case qr(QR)
    }
}

extension PaymentsTransfersToolbarState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersToolbarState.Navigation: Equatable where Profile: Equatable, QR: Equatable {}
