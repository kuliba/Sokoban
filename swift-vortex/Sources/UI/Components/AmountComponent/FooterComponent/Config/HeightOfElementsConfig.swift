//
//  HeightOfElementsConfig.swift
//
//
//  Created by Andrew Kurdin on 25.12.2024.
//

import SwiftUI

public struct HeightOfElementsConfig {
        
    public let titleHeight: CGFloat
    public let textFieldHeight: CGFloat
    
    public init(
        titleHeight: CGFloat,
        textFieldHeight: CGFloat
    ) {
        self.titleHeight = titleHeight
        self.textFieldHeight = textFieldHeight
    }
}
