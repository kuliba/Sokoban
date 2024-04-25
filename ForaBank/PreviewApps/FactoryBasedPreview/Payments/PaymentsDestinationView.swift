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

#Preview {
    PaymentsDestinationView(state: .paymentFlow(.utilityServicePayment))
}
