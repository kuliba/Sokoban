//
//  PaymentFraudMockView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain
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
            
            Button("Expire", action: { event(.expired) })
                .foregroundColor(.red)
        }
        .padding()
    }
}

extension PaymentFraudMockView {
    
    typealias State = Fraud
    typealias Event = FraudEvent
}

struct PaymentFraudMockView_Previews: PreviewProvider {
    
    static var previews: some View {
        PaymentFraudMockView(state: .init(), event: { print($0) })
    }
}
