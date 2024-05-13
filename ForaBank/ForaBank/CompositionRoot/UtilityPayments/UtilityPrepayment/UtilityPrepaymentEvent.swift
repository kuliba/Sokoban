//
//  UtilityPrepaymentEvent.swift
//
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

#warning("remove?")
enum UtilityPrepaymentEvent: Equatable {
    
    case didScrollTo(Operator.ID)
    case load([Operator])
    case page([Operator])
    case search(Search)
}

extension UtilityPrepaymentEvent {
    
    typealias Operator = UtilityPaymentOperator<String>
    
    enum Search: Equatable {
        
        case entered(String)
        case processed(String)
    }
}
