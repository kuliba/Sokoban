//
//  UtilityPrepaymentFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

final class UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService> {
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
}

extension UtilityPrepaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            microServices.initiateUtilityPayment {
                
                dispatch(.initiated($0))
            }
            
        case let .startPayment(with: select):
            microServices.startPayment(select) {
                
                dispatch(.paymentStarted(.init(select: select, result: $0)))
            }
        }
    }
}

extension UtilityPrepaymentFlowEffectHandler {
    
    typealias MicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, UtilityService>
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEffect
}
