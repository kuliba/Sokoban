//
//  Array.Operator+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

extension Array where Element == Operator {
    
    static let preview: Self = [
        .init(id: "single"),
        .init(id: "singleFailure"),
        .init(id: "multiple"),
        .init(id: "multipleFailure"),
    ]
}
