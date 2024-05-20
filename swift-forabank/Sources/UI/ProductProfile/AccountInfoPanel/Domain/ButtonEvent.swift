//
//  ButtonEvent.swift
//  
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import Foundation

public enum ButtonEvent: Equatable, Hashable {
    
    case accountDetails(Card)
    case accountStatement(Card)
}
