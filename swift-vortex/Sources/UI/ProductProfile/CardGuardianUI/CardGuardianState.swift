//
//  CardGuardianState.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import Foundation

public struct CardGuardianState: Equatable {
    
    public let buttons: [_Button]
    public var event: CardGuardianEvent?
    
    public init(buttons: [_Button], event: CardGuardianEvent? = nil) {
        self.buttons = buttons
        self.event = event
    }
    
    public struct _Button: Hashable {
        
        public let event: CardGuardian.ButtonEvent
        public let title: String
        public let iconType: CardGuardian.Config.IconType
        public let subtitle: String?
        
        public init(
            event: CardGuardian.ButtonEvent,
            title: String,
            iconType: CardGuardian.Config.IconType,
            subtitle: String?
        ) {
            self.event = event
            self.title = title
            self.iconType = iconType
            self.subtitle = subtitle
        }
    }
    
    public mutating func updateEvent(
        _ newEvent: CardGuardianEvent?
    ) {
        self.event = newEvent
    }
}
