//
//  UtilityPaymentMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

struct UtilityPaymentMicroServices<LastPayment, Operator>
where Operator: Identifiable {
    
    let initiateUtilityPayment: InitiateUtilityPayment
    let paginate: Paginate
    let search: Search
}

extension UtilityPaymentMicroServices {
    
    typealias InitiateUtilityPaymentResponse = (lastPayments: [LastPayment], operators: [Operator])
    typealias InitiateUtilityPaymentCompletion = (InitiateUtilityPaymentResponse) -> Void
    typealias InitiateUtilityPayment = (@escaping InitiateUtilityPaymentCompletion) -> Void
    
    typealias Paginate = PrepaymentPickerEffectHandler<Operator>.Paginate
    typealias Search = PrepaymentPickerEffectHandler<Operator>.Search
}
