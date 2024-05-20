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
    
    typealias ButtonConfig = ButtonSimpleViewModel.Config
    
    struct Config {
        
        let title: TextConfig
        let description: TextConfig
        let subtitle: TextConfig
        
        let background: Color
        
        let requisitesButtonTitle: String
        let requisitesButtonConfig: ButtonConfig
        
        let addCompanyButtonTitle: String
        let addCompanyButtonConfiguration: ButtonConfig
        
        public init(
            title: TextConfig,
            description: TextConfig,
            subtitle: TextConfig,
            background: Color,
            requisitesButtonTitle: String,
            requisitesButtonConfig: ButtonConfig,
            addCompanyButtonTitle: String,
            addCompanyButtonConfiguration: ButtonConfig
        ) {
            self.title = title
            self.description = description
            self.subtitle = subtitle
            self.background = background
            self.requisitesButtonTitle = requisitesButtonTitle
            self.requisitesButtonConfig = requisitesButtonConfig
            self.addCompanyButtonTitle = addCompanyButtonTitle
            self.addCompanyButtonConfiguration = addCompanyButtonConfiguration
        }
    }
}
