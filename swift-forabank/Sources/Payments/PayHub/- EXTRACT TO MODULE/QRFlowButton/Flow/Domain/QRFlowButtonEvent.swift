//
//  QRFlowButtonEvent.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public enum QRFlowButtonEvent<Destination> {
    
    case buttonTap
    case setDestination(Destination)
}

extension QRFlowButtonEvent: Equatable where Destination: Equatable {}
