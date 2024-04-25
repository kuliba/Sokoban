//
//  PaymentsViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

extension PaymentsViewFactory {
    
    static var preview: Self {
        
        .init(
            makeDestinationView: PaymentsDestinationView.init,
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
}
