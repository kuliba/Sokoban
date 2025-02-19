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
        let textViewOptionsVerticalSpacing: CGFloat
        let textViewTrailingPadding: CGFloat
        let textViewVerticalSpacing: CGFloat
        
        public init(
            textViewLeadingPadding: CGFloat,
            textViewOptionsVerticalSpacing: CGFloat,
            textViewTrailingPadding: CGFloat,
            textViewVerticalSpacing: CGFloat
        ) {
            self.textViewLeadingPadding = textViewLeadingPadding
            self.textViewOptionsVerticalSpacing = textViewOptionsVerticalSpacing
            self.textViewTrailingPadding = textViewTrailingPadding
            self.textViewVerticalSpacing = textViewVerticalSpacing
        }
    }
}
