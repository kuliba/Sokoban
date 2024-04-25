//
//  PaymentsViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct PaymentsViewFactory {
    
    let makeDestinationView: MakeDestinationView
    let makePaymentButtonLabel: MakePaymentButtonLabel
}

extension PaymentsViewFactory {
    
    typealias Destination = PaymentsState.Destination
    typealias MakeDestinationView = (Destination) -> PaymentsDestinationView
    
    typealias MakePaymentButtonLabel = (PaymentsEvent.ButtonTapped) -> PaymentButtonLabel
}
