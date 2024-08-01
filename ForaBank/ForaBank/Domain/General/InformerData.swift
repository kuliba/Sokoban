//
//  InformerData.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.09.2022.
//

import SwiftUI

struct InformerData {

    let message: String
    let icon: IconType
    let color: Color
    let interval: TimeInterval
    let type: CancelableType?
    
    init(message: String, icon: IconType, color: Color = .mainColorsBlack, interval: TimeInterval = 2, type: CancelableType? = nil) {
        
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

        var image: Image {
            
            switch self {
            case .refresh: return .ic24RefreshCw
            case .check: return .ic16Check
            case .close: return .ic16Close
            case .copy: return .ic24Copy
            }
        }
    }
    
    enum CancelableType {
        
        case openAccount
        case copyInfo
    }
}

extension InformerData {
    
    static let updateFailureInfo: Self = .init(message: "Не удалось обновить продукты\nПопробуйте позже.", icon: .close)
}
