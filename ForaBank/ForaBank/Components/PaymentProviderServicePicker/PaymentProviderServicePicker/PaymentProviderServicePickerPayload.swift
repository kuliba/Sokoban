//
//  PaymentProviderServicePickerPayload.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.07.2024.
//

struct PaymentProviderServicePickerPayload: Equatable {
    
    let provider: SegmentedPaymentProvider
    let qrCode: QRCode
}
