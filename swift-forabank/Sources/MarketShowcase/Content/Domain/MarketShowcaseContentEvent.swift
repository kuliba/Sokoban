//
//  MarketShowcaseContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public enum MarketShowcaseContentEvent<Landing> {
    
    case load
    case loaded(Landing)
    case loadFailure
    case selectLandingType(String)
    case resetSelection
}

extension MarketShowcaseContentEvent: Equatable where Landing: Equatable {}

