//
//  UtilityPrepaymentView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct UtilityPrepaymentView: View {
    
    let state: State
    let event: (Event) -> Void
    let flowEvent: (FlowEvent) -> Void
    let config: Config
    
    // MARK: - Stubs
    
    private let lastPayment: LastPayment = .init(id: "last")
    private let single = Operator(id: "single")
    private let multiple = Operator(id: "multiple")
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("UtilityPrepaymentView")

            Button("LastPayment", action: { flowEvent(.select(.lastPayment(lastPayment))) })

            Button("Single service Operator", action: { flowEvent(.select(.operator(single))) })
            
            Button("Multi service Operator", action: { flowEvent(.select(.operator(multiple))) })
            
            Divider()
            
            Button("Add Company", action: { flowEvent(.addCompany) })
            
            Button("Pay by Instructions From Empty Operator List", action: { flowEvent(.payByInstructionsFromError) })
            
            Button("Pay by Instructions", action: { flowEvent(.payByInstructions) })
        }
        .padding()
    }
}

extension UtilityPrepaymentView {
    
   typealias State = UtilityPrepaymentState
   typealias Event = UtilityPrepaymentEvent
   typealias FlowEvent = UtilityPrepaymentFlowEvent
   typealias Config = UtilityPrepaymentViewConfig
}
