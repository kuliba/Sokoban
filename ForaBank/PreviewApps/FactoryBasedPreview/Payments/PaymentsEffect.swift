//
//  PaymentsEffect.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum PaymentsEffect: Equatable {
    
    case initiate(Initiate)
}

extension PaymentsEffect {
    
    enum Initiate {
        
        case utilityPayment
    }
}
