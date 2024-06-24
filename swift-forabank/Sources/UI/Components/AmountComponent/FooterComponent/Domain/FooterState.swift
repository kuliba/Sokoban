//
//  FooterState.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import Foundation

public struct FooterState: Equatable {
    
    public var amount: Decimal
    // TODO: add currency
    public var button: FooterButton
    public var style: Style
    
    public init(
        amount: Decimal,
        button: FooterButton,
        style: Style
    ) {
        self.amount = amount
        self.button = button
        self.style = style
    }
    
    public struct FooterButton: Equatable {
        
        public var title: String
        public var state: ButtonState
        
        public init(
            title: String,
            state: ButtonState
        ) {
            self.title = title
            self.state = state
        }
        
        public enum ButtonState: Equatable {
            
            case active, inactive, tapped
        }
    }
    
    public enum Style: Equatable {
        
        case amount, button
    }
}
