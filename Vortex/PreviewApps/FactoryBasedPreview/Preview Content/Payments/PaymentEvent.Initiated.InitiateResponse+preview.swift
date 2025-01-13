//
//  PaymentEvent.Initiated.InitiateResponse+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

extension PaymentEvent.Initiated.InitiateResponse {
    
    static let preview: Self = .init(lastPayments: .preview, operators: .preview)
    static let empty: Self = .init(lastPayments: [], operators: [])
}
