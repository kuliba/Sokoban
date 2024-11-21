//
//  TitleConfig.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

public struct TitleConfig: Equatable {
    
    public let text: String
    public let config: TextConfig
    public let leadingPadding: CGFloat
    
    public init(
        text: String,
        config: TextConfig,
        leadingPadding: CGFloat = 0
    ) {
        self.text = text
        self.config = config
        self.leadingPadding = leadingPadding
    }
}
