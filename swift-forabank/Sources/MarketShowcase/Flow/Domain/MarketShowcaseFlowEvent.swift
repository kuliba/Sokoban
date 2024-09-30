//
//  MarketShowcaseFlowEvent.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public enum MarketShowcaseFlowEvent<Destination, InformerPayload> {
    
    case destination(Destination)
    case failure(MarketShowcaseFlowFailureKind<InformerPayload>)
    case reset
    case select(Selection)
}

extension MarketShowcaseFlowEvent: Equatable where Destination: Equatable, InformerPayload: Equatable {}

public enum MarketShowcaseFlowFailureKind<InformerPayload> {
    
    case timeout(InformerPayload)
    case error(String)
}

extension MarketShowcaseFlowFailureKind: Equatable where InformerPayload: Equatable {}

public extension MarketShowcaseFlowEvent {
    
    enum Selection: Equatable {
        
        case goToMain
        case orderCard
        case orderSticker
        case openURL(String)
    }
}
