//
//  OperationPickerContentViewConfig.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

public struct OperationPickerContentViewConfig: Equatable {
    
    public let height: CGFloat
    public let spacing: CGFloat
    
    public init(
        height: CGFloat,
        spacing: CGFloat
    ) {
        self.height = height
        self.spacing = spacing
    }
}
