//
//  ButtonStateConfig+ext.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

public extension ButtonStateConfig {
    
    static let active: Self = .init(
        backgroundColor: .green,
        text: .init(
            textFont: .headline.weight(.black),
            textColor: .white
        )
    )
    
    static let inactive: Self = .init(
        backgroundColor: .orange.opacity(0.3),
        text: .init(
            textFont: .headline.weight(.light),
            textColor: .white.opacity(0.7)
        )
    )
}
