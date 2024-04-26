//
//  PaymentsViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct PaymentsViewFactory<DestinationView, ButtonLabel>
where DestinationView: View,
      ButtonLabel: View {
    
    let makeDestinationView: MakeDestinationView
    let makePaymentButtonLabel: MakePaymentButtonLabel
}

extension PaymentsViewFactory {
    
    typealias MakeDestinationView = (PaymentState, @escaping (PaymentEvent) -> Void) -> DestinationView
    
    typealias MakePaymentButtonLabel = (PaymentsEvent.ButtonTapped) -> ButtonLabel
}
