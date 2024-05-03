//
//  RootActions+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

extension RootActions {
    
    static let preview: Self = .init(
        spinner: .preview,
        switchTab: { print($0) }
    )
}

extension RootActions.Spinner {
    
    static let preview: Self = .init(
        hide: { print("hide spinner") },
        show: { print("show spinner") }
    )
}
