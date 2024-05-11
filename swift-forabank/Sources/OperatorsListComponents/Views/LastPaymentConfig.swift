//
//  LastPaymentConfig.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct LastPaymentConfig {
    
    let defaultImage: Image
    let backgroundColor: Color
    
    public init(
        defaultImage: Image,
        backgroundColor: Color
    ) {
        self.defaultImage = defaultImage
        self.backgroundColor = backgroundColor
    }
}
