//
//  OperatorFailureView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct OperatorFailureView<State>: View {
    
    let state: State
    let event: () -> Void
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("TBD: Operator Failure view for \(state)")
            
            Button("Pay by Instructions", action: event)
        }
    }
}

//#Preview {
//    OperatorFailureView()
//}
