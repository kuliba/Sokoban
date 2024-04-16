//
//  FooterViewConfig.swift
//
//
//  Created by Дмитрий Савушкин on 06.03.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public extension FooterView {
    
    typealias ButtonConfig = ButtonSimpleViewModel.ButtonConfiguration
    
    struct Config {
        
        let titleConfig: TextConfig
        let descriptionConfig: TextConfig
        let subtitleConfig: TextConfig
        
        let backgroundIcon: Color
        
        let requisitesButtonTitle: String
        let requisitesButtonConfig: ButtonConfig
        
        let addCompanyButtonTitle: String
        let addCompanyButtonConfiguration: ButtonConfig
        
        public init(
            titleConfig: TextConfig,
            descriptionConfig: TextConfig,
            subtitleConfig: TextConfig,
            backgroundIcon: Color,
            requisitesButtonTitle: String,
            requisitesButtonConfig: ButtonConfig,
            addCompanyButtonTitle: String,
            addCompanyButtonConfiguration: ButtonConfig
        ) {
            self.titleConfig = titleConfig
            self.descriptionConfig = descriptionConfig
            self.subtitleConfig = subtitleConfig
            self.backgroundIcon = backgroundIcon
            self.requisitesButtonTitle = requisitesButtonTitle
            self.requisitesButtonConfig = requisitesButtonConfig
            self.addCompanyButtonTitle = addCompanyButtonTitle
            self.addCompanyButtonConfiguration = addCompanyButtonConfiguration
        }
    }
}
