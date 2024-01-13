//
//  ConsentListState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

enum ConsentListState: Equatable {
    
    case collapsed(Collapsed)
    case expanded
    case collapsedError
    case expandedError
}

extension ConsentListState {
    
    struct Collapsed: Equatable {
        
        let bankNames: [String]
    }
}
