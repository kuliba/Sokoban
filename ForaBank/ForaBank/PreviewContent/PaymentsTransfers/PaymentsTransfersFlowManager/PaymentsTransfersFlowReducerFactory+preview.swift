//
//  PaymentsTransfersFlowReducerFactory+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents
import RxViewModel

extension PaymentsTransfersFlowReducerFactory
where LastPayment == OperatorsListComponents.LastPayment,
      Operator == OperatorsListComponents.Operator<String>,
      UtilityService == ForaBank.UtilityService,
      Content == UtilityPrepaymentViewModel,
      UtilityPaymentViewModel == ObservingPaymentFlowMockViewModel {
    
    static var preview: Self {
        
        return .init(
            makeUtilityPrepaymentViewModel: { .preview(initialState: .init($0)) },
            makeUtilityPaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            },
            makePaymentsViewModel: { 
                
                return .init(.emptyMock, service: .abroad, closeAction: $0)
            }
        )
    }
}

private extension RxViewModel
where State == UtilityPrepaymentState,
      Event == UtilityPrepaymentEvent,
      Effect == UtilityPrepaymentEffect {
    
    static func preview(
        initialState: UtilityPrepaymentState = .preview
    ) -> Self {
        
        let reducer = UtilityPrepaymentReducer()
        let effectHandler = UtilityPrepaymentEffectHandler()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension UtilityPrepaymentState {
    
    static let preview: Self = .init(lastPayments: [], operators: [])
}

// MARK: - Adapters

private extension UtilityPrepaymentState {
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias Payload = Event.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    init(_ payload: Payload) {
        
        self.init(
            lastPayments: payload.lastPayments,
            operators: payload.operators
        )
    }
}
