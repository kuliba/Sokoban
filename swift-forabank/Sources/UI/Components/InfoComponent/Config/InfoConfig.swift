//
//  InfoConfig.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SharedConfigs
import SwiftUI

public struct InfoConfig {
    
    let title: TextConfig
    let value: TextConfig
    
    public init(title: TextConfig, value: TextConfig) {
     
        self.title = title
        self.value = value
    }
}
