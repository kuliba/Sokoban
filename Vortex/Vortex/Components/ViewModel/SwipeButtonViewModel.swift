//
//  SwipeButtonViewModel.swift
//  Vortex
//
//  Created by Dmitry Martynov on 25.04.2023.
//

import SwiftUI

enum SwipeDirection {
    
    case left
    case right
    
    @available(iOS 15.0, *)
    init(with edge: HorizontalEdge) {
        
        switch edge {
        case .leading: self = .right
        case .trailing: self = .left
        }
    }
}

struct SwipeButtonViewModel {
    
    let type: SwipeButtonType
    let action: () -> Void
}

enum SwipeButtonType {
    
    case activate
    case add
    case remove
    
    var icon: Image {
        
        switch self {
        case .activate: return .ic24Lock
        case .add: return .ic24Eye
        case .remove: return .ic24EyeOff
        }
    }
    
    var title: String {
        
        switch self {
        case .activate: return "Активировать"
        case .add: return "Вернуть\nна главный"
        case .remove: return "Скрыть с\nглавного"
        }
    }
    
    var color: Color {
        
        switch self {
        case .activate: return .systemColorActive
        case .add: return .mainColorsBlack
        case .remove: return .mainColorsGray
        }
    }
}
