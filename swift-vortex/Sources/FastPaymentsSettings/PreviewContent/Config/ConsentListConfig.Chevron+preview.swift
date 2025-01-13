//
//  ConsentListConfig.Chevron+preview.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension ConsentListConfig.Chevron {

    static let preview: Self = .init(
        image: .init(systemName: "chevron.down"),
        color: .pink.opacity(0.5),
        title: .init(
            textFont: .footnote,
            textColor: .pink.opacity(0.5)
        )
    )
}
