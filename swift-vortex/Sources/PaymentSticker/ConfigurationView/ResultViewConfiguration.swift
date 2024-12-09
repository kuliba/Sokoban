//
//  ResultViewConfiguration.swift
//
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation
import SwiftUI

public struct ResultViewConfiguration {

    let colorSuccess: Color
    let colorWait: Color
    let colorFailed: Color
    
    let titleColor: Color
    let titleFont: Font
    
    let descriptionColor: Color
    let descriptionFont: Font
    
    let amountColor: Color
    let amountFont: Font
    
    let mainButtonColor: Color
    let mainButtonFont: Font
    let mainButtonBackgroundColor: Color
    
    public init(
        colorSuccess: Color,
        colorWait: Color,
        colorFailed: Color,
        titleColor: Color,
        titleFont: Font,
        descriptionColor: Color,
        descriptionFont: Font,
        amountColor: Color,
        amountFont: Font,
        mainButtonColor: Color,
        mainButtonFont: Font,
        mainButtonBackgroundColor: Color
    ) {
        self.colorSuccess = colorSuccess
        self.colorWait = colorWait
        self.colorFailed = colorFailed
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.descriptionColor = descriptionColor
        self.descriptionFont = descriptionFont
        self.amountColor = amountColor
        self.amountFont = amountFont
        self.mainButtonColor = mainButtonColor
        self.mainButtonFont = mainButtonFont
        self.mainButtonBackgroundColor = mainButtonBackgroundColor
    }
}
