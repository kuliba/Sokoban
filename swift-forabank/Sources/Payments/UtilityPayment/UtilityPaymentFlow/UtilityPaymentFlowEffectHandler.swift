//
//  UtilityPaymentFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentFlowEffectHandler<LastPayment, Operator>
where Operator: Identifiable {
    
    public init() {}
}

public extension UtilityPaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

public extension UtilityPaymentFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator>
    typealias Effect = UtilityPaymentFlowEffect<Operator>
}
