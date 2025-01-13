//
//  PaymentsEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

final class PaymentsEffectHandler {
    
    private let initiateUtilityPrepayment: InitiateUtilityPrepayment
    
    init(
        initiateUtilityPrepayment: @escaping InitiateUtilityPrepayment
    ) {
        self.initiateUtilityPrepayment = initiateUtilityPrepayment
    }
}

extension PaymentsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .initiate(initiate):
            handleEffect(initiate, dispatch)
            initiateUtilityPayment(dispatch)
        }
    }
}

extension PaymentsEffectHandler {
    
    typealias InitiateUtilityPaymentResponse = PaymentEvent.Initiated.InitiateResponse
    typealias InitiateUtilityPrepaymentResult = Result<InitiateUtilityPaymentResponse, Error>
    typealias InitiateUtilityPrepaymentCompletion = (InitiateUtilityPrepaymentResult) -> Void
    typealias InitiateUtilityPrepayment = (@escaping InitiateUtilityPrepaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
}

private extension PaymentsEffectHandler {
    
    func handleEffect(
        _ effect: Effect.Initiate,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .utilityPayment:
            initiateUtilityPayment(dispatch)
        }
    }
    
    func initiateUtilityPayment(
        _ dispatch: @escaping Dispatch
    ) {
        initiateUtilityPrepayment { dispatch(.init($0)) }
    }
}

private extension PaymentsEvent {
    
    init(_ result: PaymentsEffectHandler.InitiateUtilityPrepaymentResult) {
        
        self = .payment(.initiated(.utilityPayment(result.response)))
    }
}

private extension PaymentsEffectHandler.InitiateUtilityPrepaymentResult {
    
    var response: PaymentEvent.Initiated.InitiateResponse {
        
        let response = (try? self.get()) ?? ._empty
        return response.operators.isEmpty ? ._empty : response
    }
}

private extension PaymentEvent.Initiated.InitiateResponse {
    
    static let _empty: Self = .init(lastPayments: [], operators: [])
}
