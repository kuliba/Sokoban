//
//  PaymentsViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct PaymentsViewFactory<DestinationView, PaymentButtonLabel>
where DestinationView: View,
      PaymentButtonLabel: View {
    
    let makeDestinationView: MakeDestinationView
    let makePaymentButtonLabel: MakePaymentButtonLabel
}

extension PaymentsViewFactory {
    
    typealias Destination = PaymentState
    typealias MakeDestinationView = (Destination) -> DestinationView
    
    typealias PaymentButton = PaymentEvent.PaymentButton
    typealias MakePaymentButtonLabel = (PaymentButton) -> PaymentButtonLabel
}
