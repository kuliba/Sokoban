//
//  PaymentsTransfersFlowState.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public struct PaymentsTransfersFlowState<Profile, QR> {
    
    public var navigation: Navigation?
    
    public init(
        navigation: Navigation? = nil
    ) {
        self.navigation = navigation
    }
}

public extension PaymentsTransfersFlowState {
    
    enum Navigation {
        
        case destination(Destination)
        case fullScreen(FullScreen)
    }
}

public extension PaymentsTransfersFlowState.Navigation {
    
    enum Destination {
        
        case profile(Profile)
    }
    
    enum FullScreen {
        
        case qr(QR)
    }
}

extension PaymentsTransfersFlowState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersFlowState.Navigation: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersFlowState.Navigation.Destination: Equatable where Profile: Equatable {}
extension PaymentsTransfersFlowState.Navigation.FullScreen: Equatable where QR: Equatable {}
