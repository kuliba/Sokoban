//
//  AccountLinkingConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct AccountLinkingConfig {
    
    let image: Image
    let title: TextConfig
    
    public init(
        image: Image,
        title: TextConfig
    ) {
        self.image = image
        self.title = title
    }
}
