//
//  PaymentCancelledView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct PaymentCancelledView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("Payment cancelled!")
                .foregroundColor(.red)
                .frame(maxHeight: .infinity)
            
            if state {
                
                Text("time expired")
            }
            
            Divider()
            
            Button("Go to main", action: { event(()) })
        }
    }
}

extension PaymentCancelledView {
    
    typealias State = Bool
    typealias Event = ()
}
