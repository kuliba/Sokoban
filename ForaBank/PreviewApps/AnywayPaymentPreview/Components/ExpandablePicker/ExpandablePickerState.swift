//
//  ExpandablePickerState.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

struct ExpandablePickerState<Item> {
    
    let items: [Item]
    var selection: Item?
    var toggle: Toggle
    
    init(
        items: [Item],
        selection: Item? = nil,
        toggle: Toggle = .collapsed
    ) {
        self.items = items
        self.selection = selection
        self.toggle = toggle
    }
}

extension ExpandablePickerState {
    
    enum Toggle {
        
        case collapsed, expanded
    }
}

extension ExpandablePickerState: Equatable where Item: Equatable {}
