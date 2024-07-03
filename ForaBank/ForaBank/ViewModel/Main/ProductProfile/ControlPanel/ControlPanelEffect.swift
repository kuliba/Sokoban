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
    
    var id: String {
        
        switch self {
        case let .delayAlert(viewModel, _):
            return viewModel.id.uuidString 
        }
    }
}
