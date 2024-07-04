//
//  ControlPanelEffect.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import SwiftUI

enum ControlPanelEffect: Equatable {
    
    static func == (lhs: ControlPanelEffect, rhs: ControlPanelEffect) -> Bool {
        lhs.id == rhs.id
    }
    
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)
    case blockCard(ProductCardData)
    case unblockCard(ProductCardData)

    var id: String {
        
        switch self {
        case let .delayAlert(viewModel, _):
            return viewModel.id.uuidString 
        case let .blockCard(card):
            return "\(card.id)"
        case let .unblockCard(card):
            return "\(card.id)"
        }
    }
}
