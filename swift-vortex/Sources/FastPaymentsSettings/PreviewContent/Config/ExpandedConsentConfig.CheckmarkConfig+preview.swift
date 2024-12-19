//
//  ExpandedConsentConfig.CheckmarkConfig+preview.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension ExpandedConsentConfig.CheckmarkConfig {
    
    static let preview: Self = .init(
        backgroundColor: .green.opacity(0.5),
        borderColor: .green,
        color: .pink,
        image: .init(systemName: "checkmark")
    )
}
