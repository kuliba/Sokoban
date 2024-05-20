//
//  Array.LastPayment+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

extension Array where Element == LastPayment {
    
    static let preview: Self = [
        .preview,
        .init(id: "failure"),
    ]
}
