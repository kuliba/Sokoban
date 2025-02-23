//
//  StatementDetailLayoutViewConfig.swift
//  
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SwiftUI

public struct StatementDetailLayoutViewConfig: Equatable {
    
    public let insets: EdgeInsets
    public let spacing: CGFloat
    
    public init(
        insets: EdgeInsets,
        spacing: CGFloat
    ) {
        self.insets = insets
        self.spacing = spacing
    }
}
