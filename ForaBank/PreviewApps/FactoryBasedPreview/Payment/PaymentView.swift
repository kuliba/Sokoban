//
//  PaymentView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct PaymentView<UtilityPrepaymentView>: View
where UtilityPrepaymentView: View {
    
    let state: State
    let factory: Factory
    
    var body: some View {
        
        switch state {
        case let .utilityService(.prepayment(state)):
            factory.makeUtilityPrepaymentView(state)
        }
    }
}

extension PaymentView {
    
    typealias State = PaymentState
    typealias Event = PaymentEvent
    typealias Factory = PaymentViewFactory<UtilityPrepaymentView>
}

struct PaymentsDestinationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.utilityService(.prepayment(.empty)))
            preview(.prepayment(.preview))
        }
    }
    
    private static func preview(
        _ state: UtilityServicePaymentState
    ) -> some View {
        
        preview(.utilityService(state))
    }
    
    private static func preview(
        _ state: PaymentState
    ) -> some View {
        
        PaymentView(state: state, factory: .preview())
    }
}
