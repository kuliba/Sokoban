//
//  Flow+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension Flow {
    
    static let happy: Self = .init(
        loadPrePayment: .success
    )
    
    static let sad: Self = .init(
        loadPrePayment: .failure
    )
}
