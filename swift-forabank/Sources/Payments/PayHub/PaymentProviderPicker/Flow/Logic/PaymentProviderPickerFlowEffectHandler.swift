//
//  PaymentProviderPickerFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public final class PaymentProviderPickerFlowEffectHandler<Latest, Payment, PayByInstructions, Provider, Service> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider, Service>
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
    
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service>
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
                
                dispatch(.initiatePaymentResult($0))
            }
            
        case .payByInstructions:
            microServices.makePayByInstructions {
                
                dispatch(.payByInstructions($0))
            }
            
        case let .provider(provider):
            microServices.processProvider(provider) {
                
                switch $0 {
                case let .initiatePaymentResult(result):
                    dispatch(.initiatePaymentResult(result))
                    
                case let .services(services):
                    dispatch(.loadServices(services))
                    
                case .servicesFailure:
                    dispatch(.loadServices(nil))
                }
            }
        }
    }
}
