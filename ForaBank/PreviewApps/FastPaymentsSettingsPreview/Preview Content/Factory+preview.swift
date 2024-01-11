//
//  Factory+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension Factory {
    
    static let preview: Self = .init(
        makeFastPaymentsSettingsViewModel: FastPaymentsSettingsViewModel.init
    )
}
