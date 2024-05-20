//
//  PaymentsTransfersFlowReducerFactory+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

extension PaymentsTransfersFlowReducerFactory
where LastPayment == UtilityServicePaymentFlowPreview.LastPayment,
      Operator == UtilityServicePaymentFlowPreview.Operator,
      UtilityService == UtilityServicePaymentFlowPreview.UtilityService,
      Content == UtilityPrepaymentViewModel,
      PaymentViewModel == ObservingPaymentFlowMockViewModel {
    
    static var preview: Self {
        
        return .init(
            makeUtilityPrepaymentViewModel: { .preview(initialState: .init($0)) },
            makePaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            }
        )
    }
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
