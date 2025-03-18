//
//  SavingsAccountInfoConfig.swift
//
//
//  Created by Andryusina Nataly on 13.03.2025.
//

import SharedConfigs
import SwiftUI

public struct SavingsAccountInfoConfig {
    
    let bottom: CGFloat
    let disable: Item
    let enable: Item
    let imageSize: CGSize
    let paddings: EdgeInsets
    let title: TextConfig
    
    public struct Item {
        
        let color: Color
        let text: TextConfig
        
        public init(
            color: Color,
            text: TextConfig
        ) {
            self.color = color
            self.text = text
        }
    }
    
    public init(
        bottom: CGFloat,
        disable: Item,
        enable: Item,
        imageSize: CGSize,
        paddings: EdgeInsets,
        title: TextConfig
    ) {
        self.bottom = bottom
        self.disable = disable
        self.enable = enable
        self.imageSize = imageSize
        self.paddings = paddings
        self.title = title
    }
}
