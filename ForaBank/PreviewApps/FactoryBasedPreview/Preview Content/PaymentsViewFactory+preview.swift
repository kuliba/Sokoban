//
//  PaymentsViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

extension PaymentsViewFactory
where DestinationView == PaymentsDestinationView<UtilityPrepaymentView>,
      ButtonLabel == PaymentButtonLabel {
    
    static var preview: Self {
        
        .init(
            makeDestinationView: { .init(state: $0, factory: .preview) },
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
}
