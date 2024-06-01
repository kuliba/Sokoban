//
//  UtilityPrepaymentFlowMicroServices+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.05.2024.
//

extension UtilityPrepaymentFlowMicroServices
where LastPayment == UtilityPaymentLastPayment,
      Operator == UtilityPaymentOperator,
      UtilityService == ForaBank.UtilityService {
    
    static var preview: Self {
        
        return .init(
            initiateUtilityPayment: { _,_  in },
            startPayment: { _,_ in }
        )
    }
}
