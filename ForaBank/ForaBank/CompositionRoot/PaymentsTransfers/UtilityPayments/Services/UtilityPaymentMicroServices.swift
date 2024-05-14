//
//  UtilityPaymentMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

struct UtilityPaymentMicroServices<LastPayment, Operator> {
    
    let initiateUtilityPayment: InitiateUtilityPayment
}

extension UtilityPaymentMicroServices {
    
    typealias InitiateUtilityPaymentResponse = (lastPayments: [LastPayment], operators: [Operator])
    typealias InitiateUtilityPaymentCompletion = (InitiateUtilityPaymentResponse) -> Void
    typealias InitiateUtilityPayment = (@escaping InitiateUtilityPaymentCompletion) -> Void
}
