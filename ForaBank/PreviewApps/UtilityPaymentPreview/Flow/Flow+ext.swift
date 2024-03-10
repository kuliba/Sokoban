//
//  Flow+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension Flow {
    
    static let happy: Self = .init(
        loadLastPayments: .success,
        loadPrePayment: .success
    )
    
    static let sad: Self = .init(
        loadLastPayments: .failure,
        loadPrePayment: .failure
    )
}
