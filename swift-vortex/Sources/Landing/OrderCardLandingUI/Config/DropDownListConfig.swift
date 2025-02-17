//
//  DropDownListConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import SwiftUI
import SharedConfigs

public struct DropDownListConfig {
    
    let title: TextConfig
    let itemTitle: TextConfig
    let backgroundColor: Color
    
    public init(
        title: TextConfig,
        itemTitle: TextConfig,
        backgroundColor: Color
    ) {
        self.title = title
        self.itemTitle = itemTitle
        self.backgroundColor = backgroundColor
    }
}


