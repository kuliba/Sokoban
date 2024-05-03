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
    
    // MARK: - Stub
    
    private let lastPayment: LastPayment = .preview
    private let `operator` = Operator(id: UUID().uuidString)
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("UtilityPrepaymentView")

            Button("select LastPayment", action: { flowEvent(.select(.lastPayment(lastPayment))) })

            Button("select Operator", action: { flowEvent(.select(.operator(`operator`))) })
            
            Divider()
            
            Button("Add Company", action: { flowEvent(.addCompany) })
            
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
