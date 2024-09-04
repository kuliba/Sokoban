//
//  PaymentsTransfersToolbarEffectHandler.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public final class PaymentsTransfersToolbarEffectHandler {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentsTransfersToolbarEffectHandlerMicroServices
}

public extension PaymentsTransfersToolbarEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension PaymentsTransfersToolbarEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersToolbarEvent
    typealias Effect = PaymentsTransfersToolbarEffect
}
