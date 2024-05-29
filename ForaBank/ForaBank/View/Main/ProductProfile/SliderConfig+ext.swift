//
//  SliderConfig+ext.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 07.05.2024.
//

import ActivateSlider
import SwiftUI

extension SliderConfig {
    
    static let config: Self = .init(
        colors: .init(
            backgroundColor: Color.black.opacity(0.1),
            foregroundColor: .white,
            thumbIconColor: .gray),
        items: .init(
            notActivated: .notActivated,
            confirmingActivation: .confirmingActivation,
            activating: .activating,
            activated: .activated),
        sizes: .init(),
        font: .textBodyMR14180())
}

extension SliderConfig.Item {
    
    static let notActivated: Self = .init(
        icon: .ic24ArrowRight,
        title: "Активировать"
    )
    
    static let confirmingActivation: Self = .init(
        icon: .ic24Check,
        title: ""
    )
    
    static let activating: Self = .init(
        icon: .ic24RefreshCw,
        title: "Данные\nобновляются"
    )
    
    static let activated: Self = .init(
        icon: .ic24Check,
        title: "Карта\nактивирована"
    )
}
