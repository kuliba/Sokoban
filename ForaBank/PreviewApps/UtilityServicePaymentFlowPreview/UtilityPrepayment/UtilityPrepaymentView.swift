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
    
    var body: some View {
        
        List {
            
            section("Last Payments", state.lastPayments, content: lastPaymentView)
            
            section("Operators", state.operators, content: operatorView)
            
            Section {
                
                Button("Add Company", action: { flowEvent(.addCompany) })
                
                Button("Pay by Instructions", action: { flowEvent(.payByInstructions) })
                
                Button("Pay by Instructions From Empty Operator List", action: { flowEvent(.payByInstructionsFromError) })
            }
        }
    }
    
    private func section<Item: Identifiable, Content: View>(
        _ header: String,
        _ data: [Item],
        content: @escaping (Item) -> Content
    ) -> some View {
        
        Section {
            ForEach(data, content: content)
        } header: {
            Text(header)
        }
    }
    
    private func lastPaymentView(
        lastPayment: LastPayment
    ) -> some View {
        
        itemView(
            item: lastPayment,
            action: { flowEvent(.select(.lastPayment(lastPayment))) }
        )
    }
    
    private func operatorView(
        `operator`: Operator
    ) -> some View {
        
        itemView(
            item: `operator`,
            action: { flowEvent(.select(.operator(`operator`))) }
        )
    }
    
    @ViewBuilder
    private func itemView<Item: Identifiable>(
        item: Item,
        action: @escaping () -> Void
    ) -> some View where Item.ID == String {
        
        let isFailure = item.id.localizedCaseInsensitiveContains("failure")
        
        Button(item.id.prefix(16), action: action)
            .foregroundColor(isFailure ? .red : .primary)
            .contentShape(Rectangle())
    }
}

extension UtilityPrepaymentView {
    
    typealias State = UtilityPrepaymentState
    typealias Event = UtilityPrepaymentEvent
    typealias FlowEvent = UtilityPrepaymentFlowEvent
    typealias Config = UtilityPrepaymentViewConfig
}
