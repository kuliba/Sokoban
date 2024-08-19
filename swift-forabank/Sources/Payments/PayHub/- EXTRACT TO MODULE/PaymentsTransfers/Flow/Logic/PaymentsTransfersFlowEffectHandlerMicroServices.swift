//
//  PaymentsTransfersFlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public struct PaymentsTransfersFlowEffectHandlerMicroServices<Profile, QR> {
    
    public let makeProfile: MakeProfile
    public let makeQR: MakeQR
    
    public init(
        makeProfile: @escaping MakeProfile, 
        makeQR: @escaping MakeQR
    ) {
        self.makeProfile = makeProfile
        self.makeQR = makeQR
    }
}

public extension PaymentsTransfersFlowEffectHandlerMicroServices {
    
    typealias MakeProfileCompletion = (Profile) -> Void
    typealias MakeProfile = (@escaping MakeProfileCompletion) -> Void
    
    typealias MakeQRCompletion = (QR) -> Void
    typealias MakeQR = (@escaping MakeQRCompletion) -> Void
}

