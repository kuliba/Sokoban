//
//  QRFlowState.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

struct QRFlowState<Destination> {
    
    var destination: Destination?
}

extension QRFlowState: Equatable where Destination: Equatable {}
