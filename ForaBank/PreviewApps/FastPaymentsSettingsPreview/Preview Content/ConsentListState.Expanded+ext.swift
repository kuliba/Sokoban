//
//  ConsentListState.Expanded+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

extension ConsentListState.Expanded {
    
    static let preview: Self = .init(
        searchText: "",
        banks: .preview
    )
    
    static let search: Self = .init(
        searchText: "сбер",
        banks: .preview
    )
    
    static let apply: Self = .init(
        searchText: "",
        banks: .preview,
        canApply: true
    )
}
