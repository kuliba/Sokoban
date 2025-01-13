//
//  TextConfigWithAlignment.swift
//  
//
//  Created by Igor Malyarov on 13.11.2024.
//

import SwiftUI

public struct TextConfigWithAlignment: Equatable {
    
    public let text: String
    public let alignment: TextAlignment
    public let config: TextConfig
    
    public init(
        text: String,
        alignment: TextAlignment,
        config: TextConfig
    ) {
        self.text = text
        self.alignment = alignment
        self.config = config
    }
}
