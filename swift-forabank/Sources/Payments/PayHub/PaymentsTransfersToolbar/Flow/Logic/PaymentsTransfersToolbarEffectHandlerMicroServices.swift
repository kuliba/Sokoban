//
//  PaymentsTransfersToolbarEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public struct PaymentsTransfersToolbarEffectHandlerMicroServices<Profile, QR> {
    
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

public extension PaymentsTransfersToolbarEffectHandlerMicroServices {
    
    typealias MakeProfile = (@escaping (Profile) -> Void) -> Void
    typealias MakeQR = (@escaping (QR) -> Void) -> Void
}
