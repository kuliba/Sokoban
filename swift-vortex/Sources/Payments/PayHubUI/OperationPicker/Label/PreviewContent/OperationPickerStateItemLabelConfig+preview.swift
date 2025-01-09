//
//  OperationPickerStateItemLabelConfig+preview.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

extension OperationPickerStateItemLabelConfig {
    
    static let preview: Self = .init(
        iconSize: .init(width: 24, height: 24),
        exchange: .exchange,
        latestPlaceholder: .preview,
        templates: .templates
    )
}

extension OperationPickerStateItemLabelConfig.IconConfig {
 
    static let exchange: Self = .init(
        color: .primary.opacity(0.7),
        icon: .init(systemName: "dollarsign.arrow.circlepath"),
        title: "Exchange"
    )
    
    static let templates: Self = .init(
        color: .primary.opacity(0.7),
        icon: .init(systemName: "star"),
        title: "Templates"
    )
}
