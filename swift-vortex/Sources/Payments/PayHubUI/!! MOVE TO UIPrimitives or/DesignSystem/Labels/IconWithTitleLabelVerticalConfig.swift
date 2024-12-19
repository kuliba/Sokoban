//
//  IconWithTitleLabelVerticalConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SharedConfigs
import SwiftUI

public struct IconWithTitleLabelVerticalConfig: Equatable {
    
    public let circle: CGFloat
    public let frame: CGSize
    public let spacing: CGFloat
    
    public init(
        circle: CGFloat,
        frame: CGSize,
        spacing: CGFloat
    ) {
        self.circle = circle
        self.frame = frame
        self.spacing = spacing
    }
}
