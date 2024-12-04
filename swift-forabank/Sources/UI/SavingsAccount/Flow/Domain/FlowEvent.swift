//
//  FlowEvent.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

public enum FlowEvent<Destination, InformerPayload> {
    
    case destination(Destination)
    case failure(FlowFailureKind<InformerPayload>)
    case reset
    case select(Selection)
}

extension FlowEvent: Equatable where Destination: Equatable, InformerPayload: Equatable {}

public enum FlowFailureKind<InformerPayload> {
    
    case timeout(InformerPayload)
    case error(String)
}

extension FlowFailureKind: Equatable where InformerPayload: Equatable {}

public extension FlowEvent {
    
    enum Selection: Equatable {
        
        case goToMain
        case order
    }
}
