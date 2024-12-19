//
//  OperationPickerStateItemLabelConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHubUI

extension OperationPickerStateItemLabelConfig {
    
    static let iVortex: Self = .init(
        iconSize: .init(width: 24, height: 24),
        exchange: .exchange,
        latestPlaceholder: .iVortex,
        templates: .templates
    )
}

extension OperationPickerStateItemLabelConfig.IconConfig {
    
    static let exchange: Self = .init(
        color: .textSecondary,
        icon: .ic24CurrencyExchange,
        title: "Обмен валют"
    )
    
    static let templates: Self = .init(
        color: .textSecondary,
        icon: .ic24Star,
        title: "Шаблоны"
    )
}
