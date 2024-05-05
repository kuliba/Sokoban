//
//  PaymentFraudMockView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import SwiftUI

struct PaymentFraudMockView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("PaymentFraudMockView: \(String(describing: state))")
            
            Text("Fraud Detected!")
                .font(.title.bold())
                .foregroundColor(.red)
                .frame(maxHeight: .infinity)
            
            Divider()
            
            Button("Cancel", action: { event(.cancel) })
                .foregroundColor(.red)
            
            Button("Continue", action: { event(.continue) })
            
            Button("Expire", action: { event(.expire) })
                .foregroundColor(.red)
        }
        .padding()
    }
}

extension PaymentFraudMockView {
    
    typealias State = UtilityServicePaymentFlowState.Modal.Fraud
    typealias Event = FraudEvent
}

#Preview {
    PaymentFraudMockView(state: .init(), event: { print($0) })
}
