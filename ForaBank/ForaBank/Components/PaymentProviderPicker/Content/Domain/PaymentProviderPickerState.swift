//
//  PaymentProviderPickerState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProviderPickerState<Item> {
    
    let segments: [Segment<Item>]
    let qrCode: QRCode
    var selection: Selection?
    
    enum Selection {
        
        case addCompany
        case item(Item)
        case payByInstructions
    }
}

extension PaymentProviderPickerState: Equatable where Item: Equatable {}
extension PaymentProviderPickerState.Selection: Equatable where Item: Equatable {}
