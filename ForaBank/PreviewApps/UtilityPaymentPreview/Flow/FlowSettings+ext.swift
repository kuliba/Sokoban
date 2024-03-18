//
//  FlowSettings+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension FlowSettings {
    
    static let happy: Self = .init(
        loadLastPayments: .success,
        loadOperators: .success,
        loadOptions: .success
    )
    
    static let sad: Self = .init(
        loadLastPayments: .failure,
        loadOperators: .failure,
        loadOptions: .failure
    )
}
