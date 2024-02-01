//
//  CardGuardianState.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import Foundation

public struct CardGuardianState: Equatable {
    
    public let buttons: [_Button]
    public var event: CardGuardian.ButtonTapped?
    
    public init(buttons: [_Button], event: CardGuardian.ButtonTapped? = nil) {
        self.buttons = buttons
        self.event = event
    }
    
    public struct _Button: Hashable {
        
        public let event: CardGuardian.ButtonTapped
        public let title: String
        public let iconType: CardGuardian.Config.IconType
        public let subtitle: String?
        
        public init(
            event: CardGuardian.ButtonTapped,
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
}
