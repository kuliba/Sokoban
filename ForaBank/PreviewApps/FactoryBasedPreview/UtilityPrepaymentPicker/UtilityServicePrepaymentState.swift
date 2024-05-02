//
//  UtilityServicePrepaymentState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

struct UtilityServicePrepaymentState: Equatable {
    
    let lastPayments: [LastPayment]
    let operators: [Operator]
    var complete: Complete?
}

extension UtilityServicePrepaymentState {
    
    enum Complete: Equatable {
        
        case addingCompany
        case payingByInstructions
        case selected(Selected)
    }
}

extension UtilityServicePrepaymentState.Complete {
    
    enum Selected: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
