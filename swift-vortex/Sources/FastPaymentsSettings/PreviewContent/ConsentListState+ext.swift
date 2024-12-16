//
//  ConsentListState+ext.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public extension ConsentListState {
    
    static let collapsedEmpty: Self = .success(.init(
        banks: .init(banks: .preview, consent: [])
    ))
    
    static let collapsedPreview: Self = .success(.init(
        banks: .init(banks: .preview, consent: .preview)
    ))
    
    static let expandedEmpty: Self = .success(.init(
        banks: .init(banks: .preview, consent: []),
        mode: .expanded
    ))
    
    static let expandedPreview: Self = .success(.init(
        banks: .init(banks: .preview, consent: .preview),
        mode: .expanded
    ))
    
    static func expanded(
        _ banks: [ConsentList.SelectableBank],
        consent: Set<Bank.ID> = [],
        searchText: String = ""
    ) -> Self {
        
        .success(.init(
            banks: .init(banks: .preview, consent: consent),
            mode: .expanded,
            searchText: searchText
        ))
    }
}
