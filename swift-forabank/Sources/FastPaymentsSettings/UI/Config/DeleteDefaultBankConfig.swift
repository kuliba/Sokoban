//
//  DeleteDefaultBankConfig.swift
//  
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

import SwiftUI
import SharedConfigs

public struct DeleteDefaultBankConfig {
    
    let title: String
    let titleConfig: TextConfig
    let description: String
    let descriptionConfig: TextConfig
    let icon: Image
    let buttonIcon: Image
    
    public init(
        title: String,
        titleConfig: TextConfig,
        description: String,
        descriptionConfig: TextConfig,
        icon: Image,
        buttonIcon: Image
    ) {
        self.title = title
        self.titleConfig = titleConfig
        self.description = description
        self.descriptionConfig = descriptionConfig
        self.icon = icon
        self.buttonIcon = buttonIcon
    }
}
