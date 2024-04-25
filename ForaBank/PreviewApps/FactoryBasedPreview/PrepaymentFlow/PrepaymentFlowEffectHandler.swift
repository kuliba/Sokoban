//
//  PrepaymentFlowEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PrepaymentFlowEffectHandler {
    
    private let initiateUtilityPrepayment: InitiateUtilityPrepayment
    
    init(
        initiateUtilityPrepayment: @escaping InitiateUtilityPrepayment
    ) {
        self.initiateUtilityPrepayment = initiateUtilityPrepayment
    }
}

extension PrepaymentFlowEffectHandler {
    
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

extension PrepaymentFlowEffectHandler {
    
    typealias InitiateUtilityPrepaymentResponse = PrepaymentFlowEvent.Loaded.UtilityPaymentResponse
    typealias InitiateUtilityPrepaymentResult = Result<InitiateUtilityPrepaymentResponse, Error>
    typealias InitiateUtilityPrepaymentCompletion = (InitiateUtilityPrepaymentResult) -> Void
    typealias InitiateUtilityPrepayment = (@escaping InitiateUtilityPrepaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrepaymentFlowEvent
    typealias Effect = PrepaymentFlowEffect
}

private extension PrepaymentFlowEffectHandler {
    
    func initiateUtilityPayment(
        _ dispatch: @escaping Dispatch
    ) {
        initiateUtilityPrepayment { dispatch(.init($0)) }
    }
}

private extension PrepaymentFlowEvent {
    
    init(_ result: PrepaymentFlowEffectHandler.InitiateUtilityPrepaymentResult) {
        
        self = .loaded(.utilityPayment(result.response))
    }
}

private extension PrepaymentFlowEffectHandler.InitiateUtilityPrepaymentResult {
    
    var response: PrepaymentFlowEvent.Loaded.UtilityPaymentResponse {
        
        let response = (try? self.get()) ?? ._empty
        return response.operators.isEmpty ? ._empty : response
    }
}

private extension PrepaymentFlowEvent.Loaded.UtilityPaymentResponse {
    
    static let _empty: Self = .init(lastPayments: [], operators: [])
}
