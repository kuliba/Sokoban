//
//  FlowSettings+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension FlowSettings {
    
    static let happy: Self = .init(
        loadOperators: .success,
        loadPrepayment: .success
    )
    
    static let sad: Self = .init(
        loadOperators: .failure,
        loadPrepayment: .failure
    )
}
