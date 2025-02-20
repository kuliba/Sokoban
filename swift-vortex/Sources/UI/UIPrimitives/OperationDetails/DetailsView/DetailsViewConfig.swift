//
//  DetailsViewConfig.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import Foundation

public struct DetailsViewConfig: Equatable {
    
    public let padding: CGFloat
    public let spacing: CGFloat
    
    public init(
        padding: CGFloat,
        spacing: CGFloat
    ) {
        self.padding = padding
        self.spacing = spacing
    }
}
