//
//  ErrorConfig.swift
//
//
//  Created by Дмитрий Савушкин on 24.07.2024.
//

import SharedConfigs

public struct ErrorConfig {
    
    let title: String
    public let titleConfig: TextConfig
    
    public init(
        title: String,
        titleConfig: TextConfig
    ) {
        self.title = title
        self.titleConfig = titleConfig
    }
}
