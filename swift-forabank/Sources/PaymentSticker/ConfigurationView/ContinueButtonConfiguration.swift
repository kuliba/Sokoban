//
//  ContinueButtonConfiguration.swift
//
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation
import SwiftUI

public struct ContinueButtonConfiguration {

    let activeColor: Color
    let inActiveColor: Color
    let textFont: Font
    let textColor: Color
    
    public init(
        activeColor: Color,
        inActiveColor: Color,
        textFont: Font,
        textColor: Color
    ) {
        self.activeColor = activeColor
        self.inActiveColor = inActiveColor
        self.textFont = textFont
        self.textColor = textColor
    }
}
