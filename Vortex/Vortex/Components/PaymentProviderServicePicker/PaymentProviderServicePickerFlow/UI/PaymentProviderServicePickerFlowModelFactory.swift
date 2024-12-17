//
//  PaymentProviderServicePickerFlowModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.07.2024.
//

import Foundation

struct PaymentProviderServicePickerFlowModelFactory {
    
    let makeServicePaymentBinder: MakeServicePaymentBinder
}

extension PaymentProviderServicePickerFlowModelFactory {
    
   typealias MakeServicePaymentBinder = (AnywayTransactionState.Transaction) -> ServicePaymentBinder
}
