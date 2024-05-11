//
//  PaymentsTransfersFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents
import ForaTools
import Foundation

final class PaymentsTransfersFlowComposer {
    
    private let makeReducerFactory: MakeReducerFactory
    private let makeUtilityFlowEffectHandler: MakeUtilityFlowEffectHandler
    
    init(
        makeReducerFactory: @escaping MakeReducerFactory,
        makeUtilityFlowEffectHandler: @escaping MakeUtilityFlowEffectHandler
    ) {
        self.makeReducerFactory = makeReducerFactory
        self.makeUtilityFlowEffectHandler = makeUtilityFlowEffectHandler
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias LastPayment = OperatorsListComponents.LastPayment
    typealias Operator = OperatorsListComponents.Operator
    
#warning("replace UtilityFlowEffectHandler with closure")
    typealias UtilityFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    typealias MakeUtilityFlowEffectHandler = () -> UtilityFlowEffectHandler
    
    typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, UtilityContent, ObservingPaymentFlowMockViewModel>
    
    typealias MakeReducerFactory = () -> Reducer.Factory
}

extension PaymentsTransfersFlowComposer {
    
    func makeFlowManager(
    ) -> PTFlowManger {
        
        let utilityFlowEffectHandler = makeUtilityFlowEffectHandler()
        
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            utilityEffectHandle: utilityFlowEffectHandler.handleEffect(_:_:)
        )
        
        let factory = makeReducerFactory()
        let makeReducer = {
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0, $1).reduce(_:_:) }
        )
    }
    
    typealias UtilityContent = UtilityPrepaymentViewModel
    typealias PTFlowManger = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, UtilityContent, ObservingPaymentFlowMockViewModel>
}
