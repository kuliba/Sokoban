//
//  SliderConfig.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

public struct SliderConfig {
    
    let notActivated: Item
    let waiting: Item
    let activating: Item
    let activated: Item
    
    let thumbIconColor: Color
    let foregroundColor: Color
    
    let font: Font

    public struct Item {
        
        let icon: Image
        let title: String
        
        public init(
            icon: Image,
            title: String
        ) {
            self.icon = icon
            self.title = title
        }
    }
    
    public init(
        notActivated: Item,
        waiting: Item,
        activating: Item,
        activated: Item,
        thumbIconColor: Color = .black,
        foregroundColor: Color = .white,
        font: Font
    ) {
        self.notActivated = notActivated
        self.waiting = waiting
        self.activating = activating
        self.activated = activated
        self.thumbIconColor = thumbIconColor
        self.foregroundColor = foregroundColor
        self.font = font
    }
    
    func itemByState(_ state: SliderState) -> Item {
        
        switch state {
            
        case .notActivated:
            return self.notActivated
        case .waiting:
            return self.waiting
        case .activating:
            return self.activating
        case .activated:
            return self.activated
        }
    }
    
    func thumbConfig(_ state: SliderState) -> ThumbConfig {
        
        let itemConfig = itemByState(state)
        return .init(
            icon: itemConfig.icon,
            color: self.thumbIconColor,
            backgroundColor: self.foregroundColor,
            isAnimated: state == .activating ? true : false
        )
    }
}
