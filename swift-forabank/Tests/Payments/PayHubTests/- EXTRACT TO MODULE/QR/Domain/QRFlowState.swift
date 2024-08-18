//
//  QRFlowState.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

struct QRFlowState<Destination> {
    
    var navigation: Navigation?
}

extension QRFlowState {
    
    enum Navigation {
        
        case cancel
        case destination(Destination)
    }
}

extension QRFlowState: Equatable where Destination: Equatable {}
extension QRFlowState.Navigation: Equatable where Destination: Equatable {}
