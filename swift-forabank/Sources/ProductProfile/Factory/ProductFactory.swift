//
//  ProductFactory.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import ActivateSlider
import CardGuardianModule
import RxViewModel

public struct ProductFactory {
    
    public let cardViewModel: CardViewModel
    public let cardGuardianViewModel: CardGuardianViewModel
    
    public init(
        cardViewModel: CardViewModel,
        cardGuardianViewModel: CardGuardianViewModel
    ) {
        self.cardViewModel = cardViewModel
        self.cardGuardianViewModel = cardGuardianViewModel
    }
}
