//
//  PaymentButtonLabel.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct PaymentButtonLabel: View {
    
    let state: State
    
    var body: some View {
        
        switch state {
        case .mobile:
            Text("Cellular Service")
            
        case .utilityService:
            Text("Utility Service")
        }
    }
}

extension PaymentButtonLabel {
    
    typealias State = PaymentsEvent.PaymentButton
}

#Preview {
    PaymentButtonLabel(state: .utilityService)
}
