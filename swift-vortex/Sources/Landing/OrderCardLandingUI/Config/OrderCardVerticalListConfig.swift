//
//  OrderCardVerticalListConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import SwiftUI
import SharedConfigs

public struct OrderCardVerticalListConfig {
    
    let title: TextConfig
    let itemTitle: TextConfig
    let itemSubTitle: TextConfig
    
    public init(
        title: TextConfig,
        itemTitle: TextConfig,
        itemSubTitle: TextConfig
    ) {
        self.title = title
        self.itemTitle = itemTitle
        self.itemSubTitle = itemSubTitle
    }
}
