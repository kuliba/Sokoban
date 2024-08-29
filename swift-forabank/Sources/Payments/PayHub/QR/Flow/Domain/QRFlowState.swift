//
//  QRFlowState.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public struct QRFlowState<Destination> {
    
    public var navigation: Navigation?
    
    public init(
        navigation: Navigation? = nil
    ) {
        self.navigation = navigation
    }
}

public extension QRFlowState {
    
    enum Navigation {
        
        case destination(Destination)
        case dismissed
    }
}

extension QRFlowState: Equatable where Destination: Equatable {}
extension QRFlowState.Navigation: Equatable where Destination: Equatable {}
