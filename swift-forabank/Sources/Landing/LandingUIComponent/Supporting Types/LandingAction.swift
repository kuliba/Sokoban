//
//  LandingAction.swift
//  
//
//  Created by Igor Malyarov on 04.09.2023.
//

public enum LandingAction: Equatable {
    
    case goToMain
    case orderCard(cardTarif: Int, cardType: Int)
}
