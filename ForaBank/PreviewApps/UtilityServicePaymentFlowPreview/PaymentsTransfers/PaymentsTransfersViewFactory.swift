//
//  PaymentsTransfersViewFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct PaymentsTransfersViewFactory<DestinationView: View> {
    
    let makeDestinationView: MakeDestinationView
}

extension PaymentsTransfersViewFactory {
    
    typealias Destination = PaymentsTransfersViewModel.State.Route.Destination
    typealias MakeDestinationView = (Destination) -> DestinationView
}
