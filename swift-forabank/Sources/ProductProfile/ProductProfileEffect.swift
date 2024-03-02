//
//  ProductProfileEffect.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged
import CardGuardianUI

public enum ProductProfileEffect: Equatable {
    
    case guardCard(Card)
    case toggleVisibilityOnMain(Product)
    case changePin(Card)
    case showContacts
}
