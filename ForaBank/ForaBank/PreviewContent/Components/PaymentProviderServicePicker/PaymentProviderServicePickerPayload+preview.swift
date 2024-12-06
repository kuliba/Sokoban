//
//  PaymentProviderServicePickerPayload+preview.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.07.2024.
//

import Foundation

extension PaymentProviderServicePickerPayload {
    
    static let preview: Self = .init(
        provider: .init(
            origin: .init(
                id: UUID().uuidString,
                icon: nil,
                inn: "01234556789",
                title: "Some Provider",
                segment: "Services"
            ),
            segment: "Services"
        ),
        qrCode: .init(original: "", rawData: [:]),
        qrMapping: .init(parameters: [], operators: [])
    )
}
