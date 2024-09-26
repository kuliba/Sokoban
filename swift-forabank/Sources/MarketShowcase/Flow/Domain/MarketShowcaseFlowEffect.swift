//
//  MarketShowcaseFlowEffect.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public enum MarketShowcaseFlowEffect: Equatable {
    
    case select(Selection)
}

public extension MarketShowcaseFlowEffect {
    
    enum Selection: Equatable {
        
        case orderCard
        case orderSticker
    }
}
