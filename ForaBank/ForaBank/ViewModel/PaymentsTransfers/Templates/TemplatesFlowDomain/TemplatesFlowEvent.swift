//
//  TemplatesFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.07.2024.
//

enum TemplatesFlowEvent: Equatable {
    
    case paymentTemplateSelected(PaymentTemplateData)
    case paymentInitiationResult(PaymentInitiationResult)
}

extension TemplatesFlowEvent {
    
    typealias PaymentInitiationResult = Result<Transaction, PaymentInitiationFailure>
    
    typealias Transaction = String
    
    struct PaymentInitiationFailure: Error, Equatable {
        
        let message: String?
    }
}
