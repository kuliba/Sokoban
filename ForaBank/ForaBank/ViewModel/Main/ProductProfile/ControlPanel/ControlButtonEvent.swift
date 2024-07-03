//
//  ControlButtonEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

enum ControlButtonEvent: Equatable {
    
    case blockCard(ProductCardData)
    case unblockCard(ProductCardData)
    case changePin(ProductCardData)
    case visibility(ProductCardData)
    case showAlert(ProductCardData)
}
