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
    let layout: Layout
    
    public init(
        title: TextConfig,
        optionPlaceholder: Color,
        layout: Layout
    ) {
        self.title = title
        self.optionPlaceholder = optionPlaceholder
        self.layout = layout
    }
    
    public struct Layout {
        
        let textViewLeadingPadding: CGFloat
        let textViewTrailingPadding: CGFloat
        
        public init(
            textViewLeadingPadding: CGFloat,
            textViewTrailingPadding: CGFloat
        ) {
            self.textViewLeadingPadding = textViewLeadingPadding
            self.textViewTrailingPadding = textViewTrailingPadding
        }
    }
}
