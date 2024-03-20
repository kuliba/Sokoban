//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState: Equatable {
    
    #warning("rename `route: Route``")
    var destination: Destination?
}

extension PaymentsTransfersState {
    
    enum Destination: Equatable {
        
        case utilityFlow(UtilityFlow)
        case other
    }
}

extension PaymentsTransfersState.Destination {
    
    typealias Destination = UtilityDestination<LastPayment, Operator, UtilityService>
    typealias UtilityFlow = Flow<Destination>
}
