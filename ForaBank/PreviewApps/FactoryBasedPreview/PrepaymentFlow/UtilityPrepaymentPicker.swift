//
//  UtilityPrepaymentPicker.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct UtilityPrepaymentPicker: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(state.lastPayments, content: lastPaymentView)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(state.operators, content: operatorView)
                }
            }
            
            Button("Add Company") { event(.addCompany) }
            Button("Pay by Instructions") { event(.addCompany) }
        }
        .padding()
    }
    
    private func lastPaymentView(
        lastPayment: LastPayment
    ) -> some View {
        
        Button(String(describing: lastPayment).prefix(6)) {
            
            event(.select(.lastPayment(lastPayment)))
        }
    }
    
    private func operatorView(
        `operator`: Operator
    ) -> some View {
        
        Button(String(describing: `operator`).prefix(6)) {
            
            event(.select(.operator(`operator`)))
        }
    }
}

extension UtilityPrepaymentPicker {
    
    typealias State = PrepaymentFlowState.Destination.UtilityPrepaymentState
    typealias Event = UtilityPrepaymentPickerEvent
    typealias Config = UtilityPrepaymentPickerConfig
}

struct UtilityPrepaymentPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        
        preview(.preview)
        preview(.empty)
    }
    
    static func preview(
        _ state: UtilityPrepaymentPicker.State
    ) -> some View {
        
        UtilityPrepaymentPicker(
            state: state,
            event: { _ in },
            config: .preview
        )
    }
}
