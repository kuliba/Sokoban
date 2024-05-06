//
//  PaymentsTransfersReducerFactory+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

extension PaymentsTransfersReducerFactory {
    
    static var preview: Self {
        
        return .init(
            makePaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            }
        )
    }
}
