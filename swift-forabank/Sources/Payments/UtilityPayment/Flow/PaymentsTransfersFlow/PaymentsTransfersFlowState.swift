//
//  PaymentsTransfersFlowState.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public struct PaymentsTransfersFlowState<UtilityDestination> {
    
    public var route: Route?
    
    public init(route: Route? = nil) {
     
        self.route = route
    }
}

public extension PaymentsTransfersFlowState {
    
    enum Route {
        
        case utilityFlow(UtilityFlow)
    }
}

public extension PaymentsTransfersFlowState.Route {
    
    typealias UtilityFlow = Flow<UtilityDestination>
}

extension PaymentsTransfersFlowState: Equatable where UtilityDestination: Equatable {}
extension PaymentsTransfersFlowState.Route: Equatable where UtilityDestination: Equatable {}
