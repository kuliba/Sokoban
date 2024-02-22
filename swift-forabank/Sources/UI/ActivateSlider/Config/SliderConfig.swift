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
    
    let backgroundColor: Color
    let foregroundColor: Color
    let thumbIconColor: Color
    
    let font: Font
    
    let totalWidth: CGFloat = 167
    let thumbWidth: CGFloat = 40
    let thumbPadding: CGFloat = 4
    var maxOffsetX: CGFloat { totalWidth - (thumbWidth + thumbPadding * 2) } 
    
    private var slideLength: CGFloat { totalWidth - thumbWidth - thumbPadding * 2 }
    
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
        backgroundColor: Color = Color.black.opacity(0.1),
        foregroundColor: Color = .white,
        thumbIconColor: Color = .black,
        font: Font
    ) {
        self.notActivated = notActivated
        self.waiting = waiting
        self.activating = activating
        self.activated = activated
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.thumbIconColor = thumbIconColor
        self.font = font
    }
    
    func itemForState(_ state: CardState.Status?) -> Item {
        
        switch state {
        case .activated:
            return activated
            
        case .confirmActivate:
            return waiting
            
        case .inflight:
            return activating
            
        case .none:
            return notActivated
        }
    }
    
    func thumbConfig(_ state: CardState.Status?) -> ThumbConfig {
        
        let itemConfig = itemForState(state)
        let isAnimated: Bool = {
            
            if case .inflight = state { return true }
            return false
        }()
        
        return .init(
            icon: itemConfig.icon,
            color: thumbIconColor,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            isAnimated: isAnimated
        )
    }
    
    func progressBy(
        offsetX: CGFloat
    ) -> CGFloat {
        
        1 - (slideLength - offsetX) / slideLength
    }
    
    func titleOpacityBy(
        offsetX: CGFloat
    ) -> CGFloat {
        
        max(1 - (progressBy(offsetX: offsetX) * 2), 0)
    }
    
    func backgroundOpacityBy(
        offsetX: CGFloat
    ) -> CGFloat {
        
        max(1 - (progressBy(offsetX: offsetX) * 2), 0.7)
    }
    
}
