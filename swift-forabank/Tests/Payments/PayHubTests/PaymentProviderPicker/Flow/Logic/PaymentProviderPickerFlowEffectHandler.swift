//
//  PaymentProviderPickerFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

final class PaymentProviderPickerFlowEffectHandler<Latest, Payment, PayByInstructions, Provider, Service> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider, Service>
}

extension PaymentProviderPickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
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
                        dispatch(.services(services))
                        
                    case .servicesFailure:
                        dispatch(.servicesFailure)
                    }
                }
            }
        }
    }
}

extension PaymentProviderPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

