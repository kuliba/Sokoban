//
//  PaymentsTransfersEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEffect: Equatable {
    
    case utilityPayment(UtilityFlowEffect)
}

extension PaymentsTransfersEffect {
    
    typealias UtilityFlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator>
}
