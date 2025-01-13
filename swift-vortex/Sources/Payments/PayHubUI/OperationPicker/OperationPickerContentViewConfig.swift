//
//  OperationPickerContentViewConfig.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

public struct OperationPickerContentViewConfig: Equatable {
    
    public let height: CGFloat
    public let horizontalPadding: CGFloat
    public let spacing: CGFloat
    
    public init(
        height: CGFloat,
        horizontalPadding: CGFloat,
        spacing: CGFloat
    ) {
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.spacing = spacing
    }
}
