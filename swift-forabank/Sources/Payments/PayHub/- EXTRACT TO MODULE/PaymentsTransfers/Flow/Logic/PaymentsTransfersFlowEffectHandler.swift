//
//  PaymentsTransfersFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public final class PaymentsTransfersFlowEffectHandler<Profile, QR> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentsTransfersFlowEffectHandlerMicroServices<Profile, QR>
}

public extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .profile:
            handleProfile(dispatch)
            
        case .qr:
            handleQR(dispatch)
        }
    }
}

public extension PaymentsTransfersFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersFlowEvent<Profile, QR>
    typealias Effect = PaymentsTransfersFlowEffect
}

private extension PaymentsTransfersFlowEffectHandler {
    
    func handleProfile(
        _ dispatch: @escaping Dispatch
    ) {
        microServices.makeProfile { dispatch(.profile($0)) }
    }
    
    func handleQR(
        _ dispatch: @escaping Dispatch
    ) {
        microServices.makeQR { dispatch(.qr($0)) }
    }
}
