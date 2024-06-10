//
//  PaymentFlowModalView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct PaymentFlowModalView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        switch state {
        case let .fraud(fraud):
            PaymentFraudMockView(state: fraud, event: event)
        }
    }
}

extension PaymentFlowModalView {
    
    typealias UtilityPaymentViewModel = CachedAnywayTransactionViewModel
    typealias UtilityServiceFlowState = UtilityServicePaymentFlowState<UtilityPaymentViewModel>

    typealias State = UtilityServiceFlowState.Modal
    typealias Event = ModalEvent
    typealias ModalEvent = FraudEvent // while only one Modal
}

struct PaymentFlowModalView_Previews: PreviewProvider {
    
    static var previews: some View {
        PaymentFlowModalView(state: .fraud(.init()), event: { print($0) })
    }
}
