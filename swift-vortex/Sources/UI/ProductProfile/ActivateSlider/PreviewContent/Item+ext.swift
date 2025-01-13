//
//  Item+ext.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

extension SliderConfig.Item {
    
    static let notActivated: Self = .init(
        icon: Image(systemName: "arrow.right"),
        title: "Активировать"
    )
    
    static let confirmingActivation: Self = .init(
        icon: Image(systemName: "checkmark"),
        title: ""
    )
    
    static let activating: Self = .init(
        icon: Image(systemName: "arrow.clockwise"),
        title: "Данные\nобновляются"
    )
    
    static let activated: Self = .init(
        icon: Image(systemName: "checkmark"),
        title: "Карта\nактивирована"
    )
}

