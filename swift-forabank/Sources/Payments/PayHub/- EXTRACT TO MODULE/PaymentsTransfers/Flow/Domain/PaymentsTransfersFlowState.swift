//
//  PaymentsTransfersFlowState.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public typealias PaymentsTransfersFlowState<Profile, QR> = Optional<PaymentsTransfersFlowNavigation<Profile, QR>>

public enum PaymentsTransfersFlowNavigation<Profile, QR> {
    
    case destination(Destination)
    case fullScreen(FullScreen)
}

public extension PaymentsTransfersFlowNavigation {
    
    enum Destination {
        
        case profile(Profile)
    }
    
    enum FullScreen {
        
        case qr(QR)
    }
}

extension PaymentsTransfersFlowNavigation: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersFlowNavigation.Destination: Equatable where Profile: Equatable {}
extension PaymentsTransfersFlowNavigation.FullScreen: Equatable where QR: Equatable {}
