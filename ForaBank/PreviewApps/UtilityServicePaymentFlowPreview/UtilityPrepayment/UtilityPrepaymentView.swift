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
    
    #warning("replace stub with state")
    // MARK: - Stubs
    
    private let lastPayment: LastPayment = .preview
    private let lastPaymentFailure: LastPayment = .init(id: "failure")
    
    private let single = Operator(id: "single")
    private let singleFailure = Operator(id: "singleFailure")
    private let multiple = Operator(id: "multiple")
    private let multipleFailure = Operator(id: "multipleFailure")
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Button("LastPayment", action: { flowEvent(.select(.lastPayment(lastPayment))) })
            
            Button("LastPayment Failure", action: { flowEvent(.select(.lastPayment(lastPaymentFailure))) })
                .foregroundColor(.red)
            
            Button("Single service Operator", action: { flowEvent(.select(.operator(single))) })
            
            Button("Single service Operator Failure", action: { flowEvent(.select(.operator(singleFailure))) })
                .foregroundColor(.red)
            
            Button("Multi service Operator", action: { flowEvent(.select(.operator(multiple))) })
            
            Button("Multi service Operator Failure", action: { flowEvent(.select(.operator(multipleFailure))) })
                .foregroundColor(.red)
            
            Divider()
            
            Button("Add Company", action: { flowEvent(.addCompany) })
            
            Button("Pay by Instructions", action: { flowEvent(.payByInstructions) })
            
            Button("Pay by Instructions From Empty Operator List", action: { flowEvent(.payByInstructionsFromError) })
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
