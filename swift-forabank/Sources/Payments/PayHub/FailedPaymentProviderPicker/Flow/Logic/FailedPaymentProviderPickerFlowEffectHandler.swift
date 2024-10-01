//
//  FailedPaymentProviderPickerFlowEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

public final class FailedPaymentProviderPickerFlowEffectHandler<Destination> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = FailedPaymentProviderPickerFlowEffectHandlerMicroServices<Destination>
}

public extension FailedPaymentProviderPickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .select(.detailPay):
            microServices.makeDestination { dispatch(.destination($0)) }
        }
    }
}

public extension FailedPaymentProviderPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FailedPaymentProviderPickerFlowEvent<Destination>
    typealias Effect = FailedPaymentProviderPickerFlowEffect
}
