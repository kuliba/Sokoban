//
//  ConsentListState+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

extension ConsentListState {
    
    static let collapsedEmpty: Self = .consentList(.init(
        banks: [],
        consent: [],
        mode: .collapsed,
        searchText: ""
    ))
    
    static let collapsedPreview: Self = .consentList(.init(
        banks: .preview,
        consent: [],
        mode: .collapsed,
        searchText: ""
    ))
    
    
    static func expanded(
        _ banks: [ConsentListState.ConsentList.SelectableBank],
        consent: Set<Bank.ID> = [],
        searchText: String = ""
    ) -> Self {
        
        .consentList(.init(
            banks: banks,
            consent: consent,
            mode: .expanded,
            searchText: searchText
        ))
    }
}
