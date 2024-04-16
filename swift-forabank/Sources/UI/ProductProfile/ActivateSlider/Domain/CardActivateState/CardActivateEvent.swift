//
//  CardActivateEvent.swift
//  
//
//  Created by Andryusina Nataly on 28.02.2024.
//

public enum CardActivateEvent: Equatable {
    
    case card(CardEvent)
    case slider(SliderEvent)
}
