//
//  PaymentFlowEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentFlowEffectHandler {
    
    private let initiateUtilityPayment: InitiateUtilityPayment
    
    init(
        initiateUtilityPayment: @escaping InitiateUtilityPayment
    ) {
        self.initiateUtilityPayment = initiateUtilityPayment
    }
}

extension PaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiateUtilityPayment:
            initiateUtilityPayment(dispatch)
        }
    }
}

extension PaymentFlowEffectHandler {
    
    typealias InitiateUtilityPaymentResponse = PaymentFlowEvent.Loaded.UtilityPaymentResponse
    typealias InitiateUtilityPaymentResult = Result<InitiateUtilityPaymentResponse, Error>
    typealias InitiateUtilityPaymentCompletion = (InitiateUtilityPaymentResult) -> Void
    typealias InitiateUtilityPayment = (@escaping InitiateUtilityPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentFlowEvent
    typealias Effect = PaymentFlowEffect
}

private extension PaymentFlowEffectHandler {
    
    func initiateUtilityPayment(
        _ dispatch: @escaping Dispatch
    ) {
        initiateUtilityPayment { dispatch(.init($0)) }
    }
}

private extension PaymentFlowEvent {
    
    init(_ result: PaymentFlowEffectHandler.InitiateUtilityPaymentResult) {
        
        self = .loaded(.utilityPayment(result.response))
    }
}

private extension PaymentFlowEffectHandler.InitiateUtilityPaymentResult {
    
    var response: PaymentFlowEvent.Loaded.UtilityPaymentResponse {
        
        let response = (try? self.get()) ?? ._empty
        return response.operators.isEmpty ? ._empty : response
    }
}

private extension PaymentFlowEvent.Loaded.UtilityPaymentResponse {
    
    static let _empty: Self = .init(lastPayments: [], operators: [])
}
