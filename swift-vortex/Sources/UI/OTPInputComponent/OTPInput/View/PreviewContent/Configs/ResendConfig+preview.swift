//
//  ResendConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

extension ResendConfig {
    
    static let preview: Self = .init(
        backgroundColor: .orange.opacity(0.3),
        text: .init(
            textFont: .caption, 
            textColor: .green
        )
    )
}
