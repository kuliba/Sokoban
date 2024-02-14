//
//  ShowOnMainEvent.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged
import CardGuardianModule

public enum ShowOnMainEvent: Equatable {
    
    case showOnMain(Product)
    case hideFromMain(Product)
}
