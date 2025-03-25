//
//  Untitled.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 11.03.2025.
//

import SwiftUI

struct PreviewInformerPayload: Equatable {
    
    let message: String
    let icon: IconType
    let color: Color
    let interval: TimeInterval
    let type: CancelableType?
    
    init(
        message: String,
        icon: IconType,
        color: Color = .white,
        interval: TimeInterval = 2,
        type: CancelableType? = nil
    ) {
        
        self.message = message
        self.icon = icon
        self.color = color
        self.interval = interval
        self.type = type
    }
    
    enum IconType {
        
        case refresh
        case check
        case close
        case copy
        case wifiOff
        
        var image: Image {
            
            switch self {
            case .refresh: return .iconPlaceholder
            case .check: return .iconPlaceholder
            case .close: return .iconPlaceholder
            case .copy: return .iconPlaceholder
            case .wifiOff: return .iconPlaceholder
            }
        }
    }
    
    enum CancelableType {
        
        case openAccount
        case copyInfo
    }
}
