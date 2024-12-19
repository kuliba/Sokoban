//
//  ConsentListState.UIState.Expanded+ext.swift
//  
//
//  Created by Igor Malyarov on 13.01.2024.
//

extension ConsentListState.UIState.Expanded {
    
    static func preview(
        searchText: String = ""
    ) -> Self {
     
        .init(
            searchText: searchText,
            banks: .preview,
            canApply: false
        )
    }
    
    static let consented: Self = .init(
        searchText: "",
        banks: .consented(),
        canApply: false
    )
    
    static func many(
        searchText: String = ""
    ) -> Self {
        
        .init(
            searchText: searchText,
            banks: .many,
            canApply: false
        )
    }
    
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
