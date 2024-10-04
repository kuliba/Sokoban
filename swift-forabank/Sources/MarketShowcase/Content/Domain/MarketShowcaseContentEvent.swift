//
//  MarketShowcaseContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public enum MarketShowcaseContentEvent<Landing, InformerPayload> {
    
    case load
    case loaded(Landing)
    case failure(FailureKind)
    case selectLandingType(String)
    case resetSelection
    
    public enum FailureKind {
        case alert(String)
        case informer(InformerPayload)
    }
}

extension MarketShowcaseContentEvent: Equatable where Landing: Equatable, InformerPayload: Equatable {}

extension MarketShowcaseContentEvent.FailureKind: Equatable where InformerPayload: Equatable {}
