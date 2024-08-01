//
//  ExpandablePickerEvent.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

enum ExpandablePickerEvent<Item> {
    
    case select(Item)
    case toggle
}

extension ExpandablePickerEvent: Equatable where Item: Equatable {}
