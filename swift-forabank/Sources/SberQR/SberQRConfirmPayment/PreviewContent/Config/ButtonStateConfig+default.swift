//
//  ButtonStateConfig+default.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

extension ButtonStateConfig {
    
    static let active: Self = .init(
        backgroundColor: .green,
        text: .init(
            textFont: .headline.weight(.black),
            textColor: .pink
        )
    )
    static let inactive: Self = .init(
        backgroundColor: .green.opacity(0.5),
        text: .init(
            textFont: .headline.weight(.light),
            textColor: .black
        )
    )
}
