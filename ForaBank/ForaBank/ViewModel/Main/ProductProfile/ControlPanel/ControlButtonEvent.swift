//
//  ControlButtonEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

enum ControlButtonEvent: Equatable {
    
    case cardGuardian(ProductCardData)
    case changePin(ProductCardData)
    case visibility(ProductCardData)
}
