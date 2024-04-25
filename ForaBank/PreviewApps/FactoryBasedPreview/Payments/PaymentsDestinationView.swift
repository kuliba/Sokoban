//
//  PaymentsDestinationView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct PaymentsDestinationView: View {
    
    let state: State
    
    var body: some View {
        
        Text("Destination View: \(String(describing: state))")
    }
}

extension PaymentsDestinationView {
    
    typealias State = PaymentsState.Destination
}

struct PaymentsDestinationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.empty)
            preview(.preview)
        }
    }
    
    private static func preview(
        _ state: PaymentFlowState.Destination.UtilityPrepaymentState
    ) -> some View {
        
        PaymentsDestinationView(state: .paymentFlow(
            .utilityServicePayment(state)
        ))
    }
}
