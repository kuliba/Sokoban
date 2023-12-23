//
//  Config+default.swift
//  
//
//  Created by Igor Malyarov on 12.12.2023.
//

import PrimitiveComponents
import ProductSelectComponent
import SwiftUI

extension Config {
    
    static let `default`: Self = .init(
        amount: .default,
        background: .default,
        button: .default,
        info: .default,
        productSelect: .default
    )
}

extension Config.Background {
    
    static let `default`: Self = .init(
        color: .gray.opacity(0.2)
    )
}
