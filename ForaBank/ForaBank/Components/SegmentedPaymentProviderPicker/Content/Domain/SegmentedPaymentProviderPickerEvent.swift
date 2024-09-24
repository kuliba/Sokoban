//
//  SegmentedPaymentProviderPickerEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

enum SegmentedPaymentProviderPickerEvent<Item> {
    
    case deselect
    case select(Select)
}

extension SegmentedPaymentProviderPickerEvent {
    
    enum Select {
        
        case addCompany
        case item(Item)
        case payByInstructions
    }
}

extension SegmentedPaymentProviderPickerEvent: Equatable where Item: Equatable {}
extension SegmentedPaymentProviderPickerEvent.Select: Equatable where Item: Equatable {}
