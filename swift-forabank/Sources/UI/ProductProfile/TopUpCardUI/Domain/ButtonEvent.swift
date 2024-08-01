//
//  ButtonEvent.swift
//  
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Foundation

public enum ButtonEvent: Equatable, Hashable {
    
    case accountOurBank(Card)
    case accountAnotherBank(Card)
}
