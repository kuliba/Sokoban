//
//  ProductProfileEvent.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged

public enum ProductProfileEvent: Equatable {
    
    case appear
    
    case cardGuardian(GuardianEvent)
    case showOnMain(ShowOnMainEvent)
    case changePin
}
