//
//  PaymentProviderServicePickerPayload+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.07.2024.
//

import Foundation

#if DEBUG || MOCK
extension PaymentProviderServicePickerPayload {
    
    static let preview: Self = .init(
        provider: .init(
            id: UUID().uuidString,
            icon: nil,
            inn: nil,
            title: "Some Provider",
            segment: "Services",
            origin: .provider(.init(
                id: UUID().uuidString,
                inn: UUID().uuidString,
                md5Hash: nil,
                title: UUID().uuidString,
                sortedOrder: .random(in: 1...100)
            ))
        ),
        qrCode: .init(original: "", rawData: [:])
    )
}
#endif
