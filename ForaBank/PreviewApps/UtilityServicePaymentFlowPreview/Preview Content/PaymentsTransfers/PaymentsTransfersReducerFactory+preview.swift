//
//  PaymentsTransfersReducerFactory+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

extension PaymentsTransfersReducerFactory
where Content == UtilityPrepaymentViewModel,
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
    
    init(_ payload: UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload) {
        
        self.init(
            lastPayments: payload.lastPayments,
            operators: payload.operators
        )
    }
}
