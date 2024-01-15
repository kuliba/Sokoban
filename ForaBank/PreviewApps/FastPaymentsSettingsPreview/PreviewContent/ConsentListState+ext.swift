//
//  ConsentListState+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

extension ConsentListState {
    
    static let collapsedEmpty: Self = .success(.init(
        banks: .preview,
        consent: [],
        mode: .collapsed,
        searchText: ""
    ))
    
    static var collapsedPreview: Self {
        
        let banks: [ConsentList.SelectableBank] = [Bank].preview.map {
            
            .init(bank: $0, isSelected: Consent.preview.contains($0.id))
        }
        
       return .success(.init(
            banks: banks,
            consent: .preview,
            mode: .collapsed,
            searchText: ""
        ))
    }
    
    static func expanded(
        _ banks: [ConsentList.SelectableBank],
        consent: Set<Bank.ID> = [],
        searchText: String = ""
    ) -> Self {
        
        .success(.init(
            banks: banks,
            consent: consent,
            mode: .expanded,
            searchText: searchText
        ))
    }
}
