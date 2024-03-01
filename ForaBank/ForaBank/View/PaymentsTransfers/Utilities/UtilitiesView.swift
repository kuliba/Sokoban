//
//  UtilitiesView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import SwiftUI

#warning("replace with types from module")
struct UtilitiesView<Footer: View>: View {
    
    let state: UtilitiesViewModel.State
    let onLatestPaymentTap: (UtilitiesViewModel.LatestPayment) -> Void
    let onOperatorTap: (UtilitiesViewModel.Operator) -> Void
    let footer: (Bool) -> Footer
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("Select Utility Payment Operator")
                .font(.title3.bold())
            
            if !state.latestPayments.isEmpty {
                
                ForEach(state.latestPayments) { latestPayment in
                    
                    Button(String(describing: latestPayment)) {
                        
                        onLatestPaymentTap(latestPayment)
                    }
                }
            }
            
            if state.operators.isEmpty {
                
                Text("No operators")
                
            } else {
                
                List {
                    
                    ForEach(state.operators) { `operator` in
                        
                        Button(`operator`.id) { onOperatorTap(`operator`) }
                    }
                }
                .listStyle(.plain)
            }
            
            footer(!state.operators.isEmpty)
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
            onOperatorTap: { _ in },
            footer: { _ in EmptyView() }
        )
    }
}
