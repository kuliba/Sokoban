//
//  InformerData.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.06.2022.
//

import SwiftUI

struct InformerData {

    let icon: Image
    let color: Color
    let message: String
    let interval: TimeInterval
    
    init(icon: Image,
         color: Color = .mainColorsBlack,
         message: String,
         interval: TimeInterval = 2) {
        
        self.icon = icon
        self.color = color
        self.message = message
        self.interval = interval
    }
}
