//
//  PaymentsTransfersPersonalFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public final class PaymentsTransfersPersonalFlowEffectHandler {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentsTransfersPersonalFlowEffectHandlerMicroServices
}

public extension PaymentsTransfersPersonalFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension PaymentsTransfersPersonalFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersPersonalFlowEvent
    typealias Effect = PaymentsTransfersPersonalFlowEffect
}
