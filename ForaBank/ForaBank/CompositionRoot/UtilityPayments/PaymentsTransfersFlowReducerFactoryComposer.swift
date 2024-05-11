//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

final class PaymentsTransfersFlowReducerFactoryComposer {
    
    private let model: Model
    
    init(
        model: Model
    ) {
        self.model = model
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeFactory() -> Reducer.Factory {
        
        return .init(
            makeUtilityPrepaymentViewModel: makeUtilityPrepaymentViewModel,
            makeUtilityPaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            },
            makePaymentsViewModel: { [self] in
                
                return .init(model, service: .requisites, closeAction: $0)
            }
        )
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias LastPayment = OperatorsListComponents.LastPayment
    typealias Operator = OperatorsListComponents.Operator<String>
    
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
