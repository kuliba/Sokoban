//
//  HeaderViewConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import SwiftUI
import SharedConfigs

public struct HeaderViewConfig {

    let title: TextConfig
    let optionPlaceholder: Color
    
    public init(
        title: TextConfig,
        optionPlaceholder: Color
    ) {
        self.title = title
        self.optionPlaceholder = optionPlaceholder
    }
}
