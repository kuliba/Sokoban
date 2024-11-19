//
//  CategoryPickerSectionContentViewConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SharedConfigs
import SwiftUI

public struct CategoryPickerSectionContentViewConfig: Equatable {
    
    public let failure: LabelConfig
    public let headerHeight: CGFloat
    public let spacing: CGFloat
    public let title: TitleConfig
    public let titlePlaceholder: TitlePlaceholder
    
    public init(
        failure: LabelConfig,
        headerHeight: CGFloat,
        spacing: CGFloat,
        title: TitleConfig,
        titlePlaceholder: TitlePlaceholder
    ) {
        self.failure = failure
        self.headerHeight = headerHeight
        self.spacing = spacing
        self.title = title
        self.titlePlaceholder = titlePlaceholder
    }
}

extension CategoryPickerSectionContentViewConfig {
    
    public struct TitlePlaceholder: Equatable {
        
        public let color: Color
        public let radius: CGFloat
        public let size: CGSize
        
        public init(
            color: Color, 
            radius: CGFloat, 
            size: CGSize
        ) {
            self.color = color
            self.radius = radius
            self.size = size
        }
    }
}
