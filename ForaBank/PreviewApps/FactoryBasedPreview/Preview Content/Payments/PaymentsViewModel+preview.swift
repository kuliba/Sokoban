//
//  PaymentsViewModel+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

extension PaymentsViewModel {
    
    static func preview(
        initialState: PaymentsState = .preview(),
        effectHandler: PaymentEffectHandler = .preview()
    ) -> Self {
        
        .init(
            initialState: initialState,
            paymentsManager: .preview,
            rootActions: { print($0) }
        )
    }
}
