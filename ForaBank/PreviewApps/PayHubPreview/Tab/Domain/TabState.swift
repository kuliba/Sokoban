//
//  TabState.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

struct TabState {
    
    let noLatest: Binder
    let noCategories: Binder
    let noBoth: Binder
    let okEmpty: Binder
    let ok: Binder
    
    var selected: Selected
}

extension TabState {
    
    typealias Binder = PaymentsTransfersBinder
    
    enum Selected: CaseIterable, Equatable {
        
        case noLatest, noCategories, noBoth, okEmpty, ok
    }
}
