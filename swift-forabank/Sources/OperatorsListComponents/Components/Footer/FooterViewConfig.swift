//
//  FooterViewConfig.swift
//
//
//  Created by Дмитрий Савушкин on 06.03.2024.
//

import Foundation
import SwiftUI

public extension FooterView {
    
    typealias ButtonConfig = ButtonSimpleViewModel.ButtonConfiguration
    
    struct Config {
        
        let titleFont: Font
        let titleColor: Color
        
        let descriptionFont: Font
        let descriptionColor: Color
        
        let subtitleFont: Font
        let subtitleColor: Color
        
        let backgroundIcon: Color
        
        let requisitesButtonTitle: String
        let requisitesButtonConfig: ButtonConfig
        
        let addCompanyButtonTitle: String
        let addCompanyButtonConfiguration: ButtonConfig
        
        public init(
            titleFont: Font,
            titleColor: Color,
            descriptionFont: Font,
            descriptionColor: Color,
            subtitleFont: Font,
            subtitleColor: Color,
            backgroundIcon: Color,
            requisitesButtonTitle: String,
            requisitesButtonConfig: ButtonConfig,
            addCompanyButtonTitle: String,
            addCompanyButtonConfiguration: ButtonConfig
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.descriptionFont = descriptionFont
            self.descriptionColor = descriptionColor
            self.subtitleFont = subtitleFont
            self.subtitleColor = subtitleColor
            self.backgroundIcon = backgroundIcon
            self.requisitesButtonTitle = requisitesButtonTitle
            self.requisitesButtonConfig = requisitesButtonConfig
            self.addCompanyButtonTitle = addCompanyButtonTitle
            self.addCompanyButtonConfiguration = addCompanyButtonConfiguration
        }
    }
}
