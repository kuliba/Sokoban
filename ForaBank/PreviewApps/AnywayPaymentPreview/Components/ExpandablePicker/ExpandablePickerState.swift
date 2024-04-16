//
//  ExpandablePickerState.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

struct ExpandablePickerState<Item> {
    
    let items: [Item]
    var selection: Item
    var toggle: Toggle
}

extension ExpandablePickerState {
    
    enum Toggle {
        
        case collapsed, expanded
    }
}

extension ExpandablePickerState: Equatable where Item: Equatable {}
