//
//  ConsentListState.UIState.Expanded+ext.swift
//  
//
//  Created by Igor Malyarov on 13.01.2024.
//

public extension ConsentListState.UIState.Expanded {
    
    static let preview: Self = .init(
        searchText: "",
        banks: .preview,
        canApply: false
    )
    
    static let many: Self = .init(
        searchText: "",
        banks: .many,
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
