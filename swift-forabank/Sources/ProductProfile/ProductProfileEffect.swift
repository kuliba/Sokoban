//
//  ProductProfileEffect.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged
import CardGuardianUI
import TopUpCardUI

public enum ProductProfileEffect: Equatable {
    
    case guardCard(CardGuardianUI.Card)
    case toggleVisibilityOnMain(Product)
    case changePin(CardGuardianUI.Card)
    case showContacts
    case accountOurBank(TopUpCardUI.Card)
    case accountAnotherBank(TopUpCardUI.Card)
}
