//
//  HeaderViewConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import SwiftUI
import SharedConfigs

public struct HeaderViewConfig {

    public let title: TextConfig
    public let optionPlaceholder: Color
    public let option: TextConfig
    public let layout: Layout
    
    public init(
        title: TextConfig,
        optionPlaceholder: Color,
        option: TextConfig,
        layout: Layout
    ) {
        self.title = title
        self.optionPlaceholder = optionPlaceholder
        self.option = option
        self.layout = layout
    }
    
    public struct Layout {
        
        public let itemOption: ItemOption
        public let textViewLeadingPadding: CGFloat
        public let textViewOptionsVerticalSpacing: CGFloat
        public let textViewTrailingPadding: CGFloat
        public let textViewVerticalSpacing: CGFloat
        
        public init(
            itemOption: ItemOption,
            textViewLeadingPadding: CGFloat,
            textViewOptionsVerticalSpacing: CGFloat,
            textViewTrailingPadding: CGFloat,
            textViewVerticalSpacing: CGFloat
        ) {
            self.itemOption = itemOption
            self.textViewLeadingPadding = textViewLeadingPadding
            self.textViewOptionsVerticalSpacing = textViewOptionsVerticalSpacing
            self.textViewTrailingPadding = textViewTrailingPadding
            self.textViewVerticalSpacing = textViewVerticalSpacing
        }
        
        public struct ItemOption {
            
            public let circleRadius: CGFloat
            public let horizontalSpacing: CGFloat
            public let optionWidth: CGFloat
            
            public init(
                circleRadius: CGFloat,
                horizontalSpacing: CGFloat,
                optionWidth: CGFloat
            ) {
                self.circleRadius = circleRadius
                self.horizontalSpacing = horizontalSpacing
                self.optionWidth = optionWidth
            }
        }
    }
}
