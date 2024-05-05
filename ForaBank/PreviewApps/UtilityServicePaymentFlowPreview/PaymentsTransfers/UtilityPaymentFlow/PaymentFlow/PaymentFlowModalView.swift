//
//  PaymentFlowModalView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct PaymentFlowModalView: View {
    
    let state: PaymentFlowState.Modal
    let event: (Event) -> Void
    
    var body: some View {
        
        switch state {
        case let .fraud(fraud):
            PaymentFraudMockView(state: fraud, event: event)
        }
    }
}

extension PaymentFlowModalView {
    
    typealias State = PaymentFlowState.Modal
    typealias Event = ModalEvent
    typealias ModalEvent = FraudEvent // while only one Modal
}

#Preview {
    PaymentFlowModalView(state: .fraud(.init()), event: { print($0) })
}
