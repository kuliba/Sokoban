//
//  UtilityPrepaymentFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

final class UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, Service> {
    
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
        case let .initiate(payload):
            microServices.initiateUtilityPayment(payload) {
                
                dispatch(.initiated($0))
            }
            
        case let .startPayment(with: select):
            microServices.processSelection(select) {
                
                dispatch(.selectionProcessed($0))
            }
        }
    }
}

extension UtilityPrepaymentFlowEffectHandler {
    
    typealias MicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, Service>
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>.UtilityPrepaymentFlowEffect
}
