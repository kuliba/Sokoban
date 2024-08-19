//
//  QRFlowButtonState.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

public struct QRFlowButtonState<Destination> {
    
    public var destination: Destination?
    
    public init(
        destination: Destination? = nil
    ) {
        self.destination = destination
    }
}

extension QRFlowButtonState: Equatable where Destination: Equatable {}
