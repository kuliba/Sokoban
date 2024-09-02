//
//  PaymentProviderPickerFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public final class PaymentProviderPickerFlowEffectHandler<Destination, Latest, Provider> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Destination, Latest, Provider>
}

public extension PaymentProviderPickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            self.handle(select, dispatch)
        }
    }
}

public extension PaymentProviderPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentProviderPickerFlowEvent<Destination, Latest, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

private extension PaymentProviderPickerFlowEffectHandler {
    
    func handle(
        _ select: Effect.Select,
        _ dispatch: @escaping Dispatch
    ) {
        switch select {
        case let .latest(latest):
            microServices.initiatePayment(latest) {
                
                dispatch(.destination($0))
            }
            
        case .payByInstructions:
            microServices.makePayByInstructions {
                
                dispatch(.destination($0))
            }
            
        case let .provider(provider):
            microServices.processProvider(provider) {
                
                dispatch(.destination($0))
            }
        }
    }
}
