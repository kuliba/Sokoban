//
//  TabState.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

struct TabState<Content> {
    
    let noLatest: Content
    let noCategories: Content
    let noBoth: Content
    let ok: Content
    
    var selected: Selected
}

extension TabState {
        
    enum Selected: CaseIterable, Equatable {
        
        case noLatest, noCategories, noBoth, ok
    }
}
