//
//  AmountConfig.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

public struct AmountConfig {
    
    let amount: TextConfig
    let backgroundColor: Color
    let button: TextConfig
    let buttonColor: Color
    let dividerColor: Color
    let title: TextConfig
    
    public init(
        amount: TextConfig, 
        backgroundColor: Color, 
        button: TextConfig,
        buttonColor: Color,
        dividerColor: Color,
        title: TextConfig
    ) {
        self.amount = amount
        self.backgroundColor = backgroundColor
        self.button = button
        self.buttonColor = buttonColor
        self.dividerColor = dividerColor
        self.title = title
    }
}
