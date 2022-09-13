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
    
    init(message: String, icon: IconType, color: Color = .mainColorsBlack, interval: TimeInterval = 2) {
        
        self.message = message
        self.icon = icon
        self.color = color
        self.interval = interval
    }
    
    enum IconType {
        
        case refresh
        case check
        case close
        
        var image: Image {
            
            switch self {
            case .refresh: return .ic24RefreshCw
            case .check: return .ic16Check
            case .close: return .ic16Close
            }
        }
    }
}
