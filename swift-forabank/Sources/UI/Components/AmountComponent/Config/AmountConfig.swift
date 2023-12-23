//
//  AmountConfig.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ButtonComponent
import PrimitiveComponents
import SwiftUI

public struct AmountConfig {
    
    let amount: TextConfig
    let backgroundColor: Color
    let button: ButtonConfig
    let dividerColor: Color
    let title: TextConfig
    
    public init(
        amount: TextConfig, 
        backgroundColor: Color, 
        button: ButtonConfig,
        dividerColor: Color,
        title: TextConfig
    ) {
        self.amount = amount
        self.backgroundColor = backgroundColor
        self.button = button
        self.dividerColor = dividerColor
        self.title = title
    }
}
