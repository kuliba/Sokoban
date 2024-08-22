//
//  PaymentsTransfersToolbarEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

struct PaymentsTransfersToolbarEffectHandlerMicroServices<Profile, QR> {
    
    let makeProfile: MakeProfile
    let makeQR: MakeQR
    
    init(
        makeProfile: @escaping MakeProfile,
        makeQR: @escaping MakeQR
    ) {
        self.makeProfile = makeProfile
        self.makeQR = makeQR
    }
}

extension PaymentsTransfersToolbarEffectHandlerMicroServices {
    
    typealias MakeProfile = (@escaping (Profile) -> Void) -> Void
    typealias MakeQR = (@escaping (QR) -> Void) -> Void
}
