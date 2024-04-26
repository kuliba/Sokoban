//
//  PaymentsViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

extension PaymentsViewFactory
where DestinationView == PaymentView<UtilityPrepaymentPickerMockView>,
      PaymentButtonLabel == FactoryBasedPreview.PaymentButtonLabel {
    
    static var preview: Self {
        
        .init(
            makeDestinationView: {
                
                .init(state: $0, event: $1, factory: .preview)
            },
            makePaymentButtonLabel: FactoryBasedPreview.PaymentButtonLabel.init
        )
    }
}
