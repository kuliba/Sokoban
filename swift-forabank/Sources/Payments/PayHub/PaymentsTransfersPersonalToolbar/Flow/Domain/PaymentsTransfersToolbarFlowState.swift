//
//  PaymentsTransfersToolbarFlowState.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public struct PaymentsTransfersToolbarFlowState<Profile, QR> {
    
    public var navigation: Navigation?
    
    public init(
        navigation: Navigation? = nil
    ) {
        self.navigation = navigation
    }
}

public extension PaymentsTransfersToolbarFlowState {
    
    enum Navigation {
        
        case profile(Profile)
        case qr(QR)
    }
}

extension PaymentsTransfersToolbarFlowState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersToolbarFlowState.Navigation: Equatable where Profile: Equatable, QR: Equatable {}
