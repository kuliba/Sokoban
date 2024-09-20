//
//  PaymentsTransfersPersonalFlowEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 12.09.2024.
//

public final class PaymentsTransfersCorporateFlowEffectHandler {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentsTransfersCorporateFlowEffectHandlerMicroServices
}

public extension PaymentsTransfersCorporateFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension PaymentsTransfersCorporateFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersCorporateFlowEvent
    typealias Effect = PaymentsTransfersCorporateFlowEffect
}
