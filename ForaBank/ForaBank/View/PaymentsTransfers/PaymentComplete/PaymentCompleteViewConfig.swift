//
//  PaymentCompleteViewConfig.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

struct PaymentCompleteViewConfig: Equatable {
    
    let fraud: FraudPaymentCompleteViewConfig
    let transaction: TransactionCompleteViewConfig
}
