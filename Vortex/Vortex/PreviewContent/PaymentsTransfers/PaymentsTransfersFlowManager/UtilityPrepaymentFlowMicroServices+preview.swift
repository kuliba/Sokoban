//
//  UtilityPrepaymentFlowMicroServices+preview.swift
//  Vortex
//
//  Created by Igor Malyarov on 17.05.2024.
//

extension UtilityPrepaymentFlowMicroServices
where LastPayment == UtilityPaymentLastPayment,
      Operator == UtilityPaymentProvider,
      Service == UtilityService {
    
    static var preview: Self {
        
        return .init(
            initiateUtilityPayment: { _,_  in },
            processSelection: { _,_ in }
        )
    }
}
