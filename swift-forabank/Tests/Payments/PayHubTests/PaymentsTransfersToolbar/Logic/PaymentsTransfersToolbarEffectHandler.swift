//
//  PaymentsTransfersToolbarEffectHandler.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

final class PaymentsTransfersToolbarEffectHandler<Profile, QR> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentsTransfersToolbarEffectHandlerMicroServices<Profile, QR>
}

extension PaymentsTransfersToolbarEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            handleSelect(select, dispatch)
        }
    }
}

extension PaymentsTransfersToolbarEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersToolbarEvent<Profile, QR>
    typealias Effect = PaymentsTransfersToolbarEffect
}

private extension PaymentsTransfersToolbarEffectHandler {
    
    func handleSelect(
        _ select: Effect.Select,
        _ dispatch: @escaping Dispatch
    ) {
        switch select {
        case .profile:
            microServices.makeProfile { dispatch(.profile($0)) }

        case .qr:
            microServices.makeQR { dispatch(.qr($0)) }
        }
    }
}
