//
//  PaymentsTransfersState.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState<UtilityDestination> {
    
    var route: Route?
}

extension PaymentsTransfersState {
    
    enum Route {
        
        case utilityFlow(UtilityFlow)
    }
}

extension PaymentsTransfersState.Route {
    
    typealias UtilityFlow = Flow<UtilityDestination>
}

extension PaymentsTransfersState: Equatable where UtilityDestination: Equatable {}
extension PaymentsTransfersState.Route: Equatable where UtilityDestination: Equatable {}
