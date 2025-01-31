//
//  SegmentedPaymentProviderPickerState.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct SegmentedPaymentProviderPickerState<Item> {
    
    let segments: [Segment<Item>]
    let qrCode: QRCode
    let qrMapping: QRMapping
}

extension SegmentedPaymentProviderPickerState: Equatable where Item: Equatable {}
