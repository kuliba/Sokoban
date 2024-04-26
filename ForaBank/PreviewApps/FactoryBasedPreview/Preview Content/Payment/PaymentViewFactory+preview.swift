//
//  PaymentViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PaymentViewFactory
where UtilityPrepaymentView == UtilityPrepaymentPickerMockView {
    
    static let preview: Self = .init(
        makeUtilityPrepaymentView: {
            
            .init(state: $0, event: $1)
        }
    )
}
