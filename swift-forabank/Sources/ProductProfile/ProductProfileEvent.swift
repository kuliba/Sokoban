//
//  ProductProfileEvent.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged
import CardGuardianModule

public enum ProductProfileEvent: Equatable {
    
    case cardGuardian(GuardianEvent)
    case showOnMain(ShowOnMainEvent)
    case changePin(Card)
    case showContacts
}
