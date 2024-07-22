//
//  ControlButtonEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import SwiftUI
import UIPrimitives

enum ControlButtonEvent: Equatable {
    
    static func == (lhs: ControlButtonEvent, rhs: ControlButtonEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    case blockCard(ProductCardData)
    case unblockCard(ProductCardData)
    case changePin(ProductCardData)
    case visibility(ProductCardData)
    case showAlert(Alert.ViewModel)
    case delayAlert(ProductCardData)
    
    var id: String {
        
        switch self {
        case let .blockCard(card):
            return "\(card.id)"
        case let .unblockCard(card):
            return "\(card.id)"
        case let .changePin(card):
            return "\(card.id)"
        case let .visibility(card):
            return "\(card.id)"
        case let .delayAlert(card):
            return "\(card.id)"

        case let .showAlert(viewModel):
            return viewModel.id.uuidString
        }
    }
}
