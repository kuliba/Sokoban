//
//  IconWithTitleLabelVerticalConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SharedConfigs
import SwiftUI

public struct IconWithTitleLabelVerticalConfig: Equatable {
    
    public let circleSize: CGFloat
    public let frame: CGSize
    public let spacing: CGFloat
    
    public init(
        circleSize: CGFloat,
        frame: CGSize,
        spacing: CGFloat
    ) {
        self.circleSize = circleSize
        self.frame = frame
        self.spacing = spacing
    }
}
