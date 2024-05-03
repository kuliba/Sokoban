//
//  PaymentsTransfersDestinationView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct PaymentsTransfersDestinationView: View {
    
    let destination: Destination
    let factory: Factory
    
    var body: some View {
        
        switch destination {
        case let .utilityFlow(utilityPaymentViewModel):
            factory.makeUtilityPrepaymentView(utilityPaymentViewModel)
        }
    }
}

extension PaymentsTransfersDestinationView {
    
    typealias Destination = PaymentsTransfersViewModel.State.Route.Destination
    typealias Factory = PaymentsTransfersDestinationViewFactory
}

#Preview {
    PaymentsTransfersDestinationView(destination: .utilityFlow(.preview()), factory: .preview)
}
