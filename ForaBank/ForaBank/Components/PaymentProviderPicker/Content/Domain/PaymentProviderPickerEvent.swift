//
//  PaymentProviderPickerEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

enum PaymentProviderPickerEvent<Item> {
    
    case deselect
    case select(Select)
}

extension PaymentProviderPickerEvent {
    
    enum Select {
        
        case addCompany
        case item(Item)
        case payByInstructions
    }
}

extension PaymentProviderPickerEvent: Equatable where Item: Equatable {}
extension PaymentProviderPickerEvent.Select: Equatable where Item: Equatable {}
