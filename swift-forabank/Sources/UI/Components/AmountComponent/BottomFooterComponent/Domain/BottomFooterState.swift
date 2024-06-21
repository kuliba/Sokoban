//
//  BottomFooterState.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import Foundation

public struct BottomFooterState: Equatable {
    
    public var amount: Decimal
    public var buttonState: ButtonState
    public var style: Style
    
    public init(
        amount: Decimal,
        buttonState: ButtonState,
        style: Style
    ) {
        self.amount = amount
        self.buttonState = buttonState
        self.style = style
    }
    
    public enum ButtonState: Equatable {
        
        case active, inactive, tapped
    }
    
    public  enum Style: Equatable {
        
        case amount, button
    }
}
