//
//  UtilitiesView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import SwiftUI

#warning("replace with types from module")
struct UtilitiesView: View {
    
    let state: UtilitiesViewModel.State
    let onLatestPaymentTap: (UtilitiesViewModel.LatestPayment) -> Void
    let onOperatorTap: (UtilitiesViewModel.Operator) -> Void
    
    var body: some View {
        
        VStack {
            
            if !state.latestPayments.isEmpty {
                
                Text(String(describing: state.latestPayments))
            }
            
            if state.operators.isEmpty {
                
                Text("No operators")
                
            } else {
                
                Text("Operators: \(String(describing: state.operators))")
            }
        }
        
    }
}

struct UtilitiesView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UtilitiesView(
            state: .init(
                latestPayments: [],
                operators: []
            ),
            onLatestPaymentTap: { _ in },
            onOperatorTap: { _ in }
        )
    }
}
