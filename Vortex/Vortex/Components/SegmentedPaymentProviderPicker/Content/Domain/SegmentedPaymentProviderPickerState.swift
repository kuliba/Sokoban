//
//  SegmentedPaymentProviderPickerState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct SegmentedPaymentProviderPickerState<Item> {
    
    let segments: [Segment<Item>]
    let qrCode: QRCode
    let qrMapping: QRMapping
    var selection: Selection?
    
    enum Selection {
        
        case addCompany
        case item(Item)
        case payByInstructions
    }
}

extension SegmentedPaymentProviderPickerState: Equatable where Item: Equatable {}
extension SegmentedPaymentProviderPickerState.Selection: Equatable where Item: Equatable {}
