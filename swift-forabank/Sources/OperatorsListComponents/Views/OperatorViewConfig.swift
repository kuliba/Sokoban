//
//  OperatorViewConfig.swift
//  
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct OperatorViewConfig {
    #warning("remove unused fields")
    let titleFont: Font
    let titleColor: Color
    
    let descriptionFont: Font
    let descriptionColor: Color
    
    let defaultIconBackgroundColor: Color
    let defaultIcon: Image
    
    public init(
        titleFont: Font,
        titleColor: Color,
        descriptionFont: Font,
        descriptionColor: Color,
        defaultIconBackgroundColor: Color,
        defaultIcon: Image
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
        self.defaultIconBackgroundColor = defaultIconBackgroundColor
        self.defaultIcon = defaultIcon
    }
}
