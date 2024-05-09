//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

final class PaymentsTransfersFlowReducerFactoryComposer {}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeFactory() -> Reducer.Factory {
        
        return .init(
            makeUtilityPrepaymentViewModel: makeUtilityPrepaymentViewModel,
            makePaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            }
        )
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias LastPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
    
    typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentViewModel(
        payload: PrepaymentPayload
    ) -> UtilityPrepaymentViewModel {
        
        let reducer = UtilityPrepaymentReducer()
        let effectHandler = UtilityPrepaymentEffectHandler()
        
        return .init(
            initialState: payload.state,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias PrepaymentPayload = Event.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
}
