//
//  QRFlowButtonState.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

struct QRFlowButtonState<Destination> {
    
    var destination: Destination?
}

extension QRFlowButtonState: Equatable where Destination: Equatable {}
