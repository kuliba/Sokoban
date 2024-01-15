//
//  ConsentListState.UIState.Expanded+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import FastPaymentsSettings

extension ConsentListState.UIState.Expanded {
    
    static let preview: Self = .init(
        searchText: "",
        banks: .preview,
        canApply: false
    )
    
    static let search: Self = .init(
        searchText: "сбер",
        banks: .preview,
        canApply: false
    )
    
    static let apply: Self = .init(
        searchText: "",
        banks: .preview,
        canApply: true
    )
}
