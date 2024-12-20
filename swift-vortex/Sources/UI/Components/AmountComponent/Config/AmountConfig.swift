//
//  AmountConfig.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ButtonComponent
import SharedConfigs
import SwiftUI

public struct AmountConfig {
    
    public let amount: TextConfig
    public let backgroundColor: Color
    public let button: ButtonConfig
    public let dividerColor: Color
    public let title: TextConfig
    
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
