//
//  TabState.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

struct TabState {
    
    let noLatest: FlowModel
    let noCategories: FlowModel
    let noBoth: FlowModel
    let okEmpty: FlowModel
    let ok: FlowModel
    
    var selected: Selected
}

extension TabState {
    
    typealias FlowModel = PaymentsTransfersModel<PayHubBinder>
    
    enum Selected: CaseIterable, Equatable {
        
        case noLatest, noCategories, noBoth, okEmpty, ok
    }
}
