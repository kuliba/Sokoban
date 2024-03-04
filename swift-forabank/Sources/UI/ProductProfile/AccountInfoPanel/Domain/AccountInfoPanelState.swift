//
//  AccountInfoPanelState.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import Foundation

public struct AccountInfoPanelState: Equatable {
    
    public let buttons: [PanelButton]
    public var event: AccountInfoPanelEvent?
    
    public init(buttons: [PanelButton], event: AccountInfoPanelEvent? = nil) {
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
        _ newEvent: AccountInfoPanelEvent?
    ) {
        self.event = newEvent
    }
}
