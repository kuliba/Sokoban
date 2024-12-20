//
//  UtilityServicePrepaymentState+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

extension UtilityServicePrepaymentState {
    
    static let empty: Self = .init(lastPayments: [], operators: [])
    static let preview: Self = .init(lastPayments: .preview, operators: .preview)
}
