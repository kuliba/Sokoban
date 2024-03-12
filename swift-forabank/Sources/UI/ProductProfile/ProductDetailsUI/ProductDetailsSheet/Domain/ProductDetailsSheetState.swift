//
//  ProductDetailsSheetState.swift
//
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Foundation

public struct ProductDetailsSheetState: Equatable {
    
    public let buttons: [PanelButton]
    public var event: ProductDetailsSheetEvent?
    
    public init(buttons: [PanelButton], event: ProductDetailsSheetEvent? = nil) {
        self.buttons = buttons
        self.event = event
    }
    
    public struct PanelButton: Hashable {
        
        let event: SheetButtonEvent
        let title: String
        let accessibilityIdentifier: String
        
        public init(
            event: SheetButtonEvent,
            title: String,
            accessibilityIdentifier: String
        ) {
            self.event = event
            self.title = title
            self.accessibilityIdentifier = accessibilityIdentifier
        }
    }
}
