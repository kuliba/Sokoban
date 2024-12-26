//
//  TextWithConfig.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import Foundation
import SharedConfigs

public struct TextWithConfig: Equatable {
    
    let text: String
    let config: TextConfig
    
    public init(
        text: String,
        config: TextConfig
    ) {
        self.text = text
        self.config = config
    }
}
