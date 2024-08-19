//
//  PaymentsTransfersFlowState.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public struct PaymentsTransfersFlowState<Profile, QR> {
    
    public var destination: Destination?
    
    public init(
        destination: Destination? = nil
    ) {
        self.destination = destination
    }
}

public extension PaymentsTransfersFlowState {
    
    enum Destination {
        
        case profile(Profile)
        case qr(QR)
    }
}

extension PaymentsTransfersFlowState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersFlowState.Destination: Equatable where Profile: Equatable, QR: Equatable {}
