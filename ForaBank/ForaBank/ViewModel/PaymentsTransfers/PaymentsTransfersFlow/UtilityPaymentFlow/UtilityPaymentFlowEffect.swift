//
//  UtilityPaymentFlowEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum UtilityPaymentFlowEffect<LastPayment, Operator, Service> {
    
    case prepayment(PrepaymentEffect)
}

extension UtilityPaymentFlowEffect {
    
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
}
