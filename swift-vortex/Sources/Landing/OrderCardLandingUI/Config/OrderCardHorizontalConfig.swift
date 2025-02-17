//
//  OrderCardHorizontalConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import SwiftUI
import SharedConfigs

public struct OrderCardHorizontalConfig {
    
    let title: TextConfig
    let itemConfig: TextConfig
    
    public init(
        title: TextConfig,
        itemConfig: TextConfig
    ) {
        self.title = title
        self.itemConfig = itemConfig
    }
}
