//
//  PaymentsTransfersFlowManager+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

extension PaymentsTransfersFlowManager
where LastPayment == UtilityPaymentLastPayment,
      Operator == UtilityPaymentOperator,
      UtilityService == ForaBank.UtilityService,
      Content == UtilityPrepaymentViewModel,
      PaymentViewModel == ObservingAnywayTransactionViewModel {
    
    static var preview: Self {
        
        return .init(
            handleEffect: { _,_ in },
            makeReduce: { _,_ in  { state,_ in (state, nil) }}
        )
    }
}
