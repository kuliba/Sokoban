//
//  BottomAmountConfig.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ButtonComponent
import SharedConfigs
import SwiftUI

public struct BottomAmountConfig {
    
    public let amount: TextConfig
    public let amountFont: UIFont
    public let backgroundColor: Color
    public let button: FooterButtonConfig
    public let buttonSize: CGSize
    public let dividerColor: Color
    public let title: String
    public let titleConfig: TextConfig
    
    public init(
        amount: TextConfig,
        amountFont: UIFont = .boldSystemFont(ofSize: 24),
        backgroundColor: Color,
        button: FooterButtonConfig,
        buttonSize: CGSize,
        dividerColor: Color,
        title: String,
        titleConfig: TextConfig
    ) {
        self.amount = amount
        self.amountFont = amountFont
        self.backgroundColor = backgroundColor
        self.button = button
        self.buttonSize = buttonSize
        self.dividerColor = dividerColor
        self.title = title
        self.titleConfig = titleConfig
    }
}
