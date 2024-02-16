//
//  LogoConfig.swift
//  
//
//  Created by Igor Malyarov on 14.02.2024.
//

import SwiftUI

public struct LogoConfig {
    
    let backgroundColor: Color
    let image: Image
    
    public init(
        backgroundColor: Color,
        image: Image
    ) {
        self.backgroundColor = backgroundColor
        self.image = image
    }
}
