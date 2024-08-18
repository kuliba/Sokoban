//
//  QRFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

enum QRFlowEvent<Destination> {

    case cancel
    case destination(Destination)
    case dismissDestination
}

extension QRFlowEvent: Equatable where Destination: Equatable{}
