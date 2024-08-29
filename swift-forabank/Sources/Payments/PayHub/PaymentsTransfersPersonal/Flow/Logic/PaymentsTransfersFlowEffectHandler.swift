//
//  PaymentsTransfersFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public final class PaymentsTransfersFlowEffectHandler {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentsTransfersFlowEffectHandlerMicroServices
}

public extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension PaymentsTransfersFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersFlowEvent
    typealias Effect = PaymentsTransfersFlowEffect
}
