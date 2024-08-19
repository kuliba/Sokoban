//
//  FlowButtonEvent.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public enum FlowButtonEvent<Destination> {
    
    case buttonTap
    case dismissDestination
    case setDestination(Destination)
}

extension FlowButtonEvent: Equatable where Destination: Equatable {}
