//
//  FlowButtonState.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

public struct FlowButtonState<Destination> {
    
    public var destination: Destination?
    
    public init(
        destination: Destination? = nil
    ) {
        self.destination = destination
    }
}

extension FlowButtonState: Equatable where Destination: Equatable {}
