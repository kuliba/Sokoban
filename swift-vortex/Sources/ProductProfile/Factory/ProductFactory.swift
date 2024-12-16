//
//  ProductFactory.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import CardGuardianUI
import RxViewModel

public struct ProductFactory {
    
    public let cardGuardianViewModel: CardGuardianViewModel
    
    public init(
        cardGuardianViewModel: CardGuardianViewModel
    ) {
        self.cardGuardianViewModel = cardGuardianViewModel
    }
}
