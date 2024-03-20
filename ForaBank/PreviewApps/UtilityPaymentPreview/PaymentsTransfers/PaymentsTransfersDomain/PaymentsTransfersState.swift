//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState: Equatable {
    
    var route: Route?
}

extension PaymentsTransfersState {
    
    enum Route: Equatable {
        
        case utilityFlow(UtilityFlow)
        case other
    }
}

extension PaymentsTransfersState.Route {
    
    typealias Destination = UtilityDestination<LastPayment, Operator, UtilityService>
    typealias UtilityFlow = Flow<Destination>
}
