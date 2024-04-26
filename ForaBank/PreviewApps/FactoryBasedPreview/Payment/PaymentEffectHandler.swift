//
//  PaymentEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentEffectHandler {
    
    private let initiateUtilityPrepayment: InitiateUtilityPrepayment
    
    init(
        initiateUtilityPrepayment: @escaping InitiateUtilityPrepayment
    ) {
        self.initiateUtilityPrepayment = initiateUtilityPrepayment
    }
}

extension PaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .utilityService(utilityServicePaymentEffect):
            utilityServicePaymentEffect
            initiateUtilityPayment(dispatch)
        }
    }
}

extension PaymentEffectHandler {
    
    typealias InitiateUtilityPaymentResponse = UtilityServicePaymentEvent.InitiateResponse
    typealias InitiateUtilityPrepaymentResult = Result<InitiateUtilityPaymentResponse, Error>
    typealias InitiateUtilityPrepaymentCompletion = (InitiateUtilityPrepaymentResult) -> Void
    typealias InitiateUtilityPrepayment = (@escaping InitiateUtilityPrepaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentEvent
    typealias Effect = PaymentEffect
}

private extension PaymentEffectHandler {
    
    func handleEffect(
        _ effect: UtilityServicePaymentEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            initiateUtilityPayment(dispatch)
        }
    }

    func initiateUtilityPayment(
        _ dispatch: @escaping Dispatch
    ) {
        initiateUtilityPrepayment { dispatch(.init($0)) }
    }
}

private extension PaymentEvent {
    
    init(_ result: PaymentEffectHandler.InitiateUtilityPrepaymentResult) {
        
        self = .utilityService(.initiated(result.response))
    }
}

private extension PaymentEffectHandler.InitiateUtilityPrepaymentResult {
    
    var response: UtilityServicePaymentEvent.InitiateResponse {
        
        let response = (try? self.get()) ?? ._empty
        return response.operators.isEmpty ? ._empty : response
    }
}

private extension UtilityServicePaymentEvent.InitiateResponse {
    
    static let _empty: Self = .init(lastPayments: [], operators: [])
}
