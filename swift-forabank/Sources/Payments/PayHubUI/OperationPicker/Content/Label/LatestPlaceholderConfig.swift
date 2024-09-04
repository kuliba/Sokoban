//
//  LatestPlaceholderConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

public struct LatestPlaceholderConfig: Equatable {
    
    public let label: IconWithTitleLabelVerticalConfig
    public let textHeight: CGFloat
    public let textSpacing: CGFloat
    public let textWidth: CGFloat
    
    public init(
        label: IconWithTitleLabelVerticalConfig,
        textHeight: CGFloat,
        textSpacing: CGFloat,
        textWidth: CGFloat
    ) {
        self.label = label
        self.textHeight = textHeight
        self.textSpacing = textSpacing
        self.textWidth = textWidth
    }
}
