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
    
    let makeUtilityFlowEffectHandler: MakeUtilityFlowEffectHandler
    
    init(
        makeUtilityFlowEffectHandler: @escaping MakeUtilityFlowEffectHandler
    ) {
        self.makeUtilityFlowEffectHandler = makeUtilityFlowEffectHandler
    }
}

extension PaymentsTransfersFlowComposer {
    
    typealias LastPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
    
#warning("replace UtilityFlowEffectHandler with closure")
    typealias UtilityFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    typealias MakeUtilityFlowEffectHandler = () -> UtilityFlowEffectHandler
}

extension PaymentsTransfersFlowComposer {
    
    typealias PTFlowManger = PaymentsTransfersFlowManager<LatestPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    
    func makeFlowManager(
    ) -> PTFlowManger {
        
        let utilityFlowEffectHandler = makeUtilityFlowEffectHandler()
        
        typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        let effectHandler = EffectHandler(
            utilityEffectHandle: utilityFlowEffectHandler.handleEffect(_:_:)
        )
        
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>

#warning("extract to helper")
        let factory = Reducer.Factory(
            makeUtilityPrepaymentViewModel: { payload in
                
                let reducer = UtilityPrepaymentReducer()
                let effectHandler = UtilityPrepaymentEffectHandler()
                
                return .init(
                    initialState: payload.state,
                    reduce: reducer.reduce(_:_:),
                    handleEffect: effectHandler.handleEffect(_:_:)
                )
            },
            makePaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            }
        )
        
        let makeReducer = { notify in
            
            Reducer(factory: factory, notify: notify)
        }
        
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0).reduce(_:_:) }
        )
    }
}
