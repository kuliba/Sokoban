//
//  Config+default.swift
//  
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

extension Config {
    
    static let `default`: Self = .init(
        background: .default,
        productSelectViewConfig: .default
    )
}

extension Config.Background {
    
    static let `default`: Self = .init(
        color: .gray.opacity(0.2)
    )
}
