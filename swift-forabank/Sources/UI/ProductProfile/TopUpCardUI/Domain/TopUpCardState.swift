//
//  TopUpCardState.swift
//  
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Foundation

public struct TopUpCardState: Equatable {
    
    public let buttons: [PanelButton]
    public var event: TopUpCardEvent?
    
    public init(buttons: [PanelButton], event: TopUpCardEvent? = nil) {
        self.buttons = buttons
        self.event = event
    }
    
    public struct PanelButton: Hashable {
        
        public let event: ButtonEvent
        public let title: String
        public let iconType: Config.IconType
        public let subtitle: String?
        
        public init(
            event: ButtonEvent,
            title: String,
            iconType: Config.IconType,
            subtitle: String?
        ) {
            self.event = event
            self.title = title
            self.iconType = iconType
            self.subtitle = subtitle
        }
    }
    
    public mutating func updateEvent(
        _ newEvent: TopUpCardEvent?
    ) {
        self.event = newEvent
    }
}
