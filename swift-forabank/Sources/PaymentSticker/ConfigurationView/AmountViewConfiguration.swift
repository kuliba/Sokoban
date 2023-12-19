//
//  AmountViewConfiguration.swift
//
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation
import SwiftUI

public struct AmountViewConfiguration {
    
    let amountFont: Font
    let amountColor: Color
    let buttonTextFont: Font
    let buttonTextColor: Color
    let buttonColor: Color
    let hintFont: Font
    let hintColor: Color
    let background: Color
    
    public init(
        amountFont: Font,
        amountColor: Color,
        buttonTextFont: Font,
        buttonTextColor: Color,
        buttonColor: Color,
        hintFont: Font,
        hintColor: Color,
        background: Color
    ) {
        self.amountFont = amountFont
        self.amountColor = amountColor
        self.buttonTextFont = buttonTextFont
        self.buttonTextColor = buttonTextColor
        self.buttonColor = buttonColor
        self.hintFont = hintFont
        self.hintColor = hintColor
        self.background = background
    }
}
