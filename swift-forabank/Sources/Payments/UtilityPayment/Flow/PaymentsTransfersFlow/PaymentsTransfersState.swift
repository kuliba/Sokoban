//
//  PaymentsTransfersState.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public struct PaymentsTransfersState<UtilityDestination> {
    
    public var route: Route?
    
    public init(route: Route? = nil) {
     
        self.route = route
    }
}

public extension PaymentsTransfersState {
    
    enum Route {
        
        case utilityFlow(UtilityFlow)
    }
}

public extension PaymentsTransfersState.Route {
    
    typealias UtilityFlow = Flow<UtilityDestination>
}

extension PaymentsTransfersState: Equatable where UtilityDestination: Equatable {}
extension PaymentsTransfersState.Route: Equatable where UtilityDestination: Equatable {}
