//
//  UtilityPrepaymentPicker.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct UtilityPrepaymentPickerMockView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        if state.operators.isEmpty {
            errorView()
        } else {
            picker()
        }
    }
    
    private func errorView() -> some View {
        
        Text("error loading operators")
            .foregroundColor(.red)
    }
    
    private func picker() -> some View {
        
        VStack(spacing: 32) {
            
            VStack(alignment: .leading, spacing: 32) {
                
                lastPaymentView(lastPayment: .preview)
                
                operatorView(operator: .single)
                operatorView(operator: .multiple)
                
                Divider()
            }
            
            VStack(alignment: .center, spacing: 32) {
                
                Button("Add Company") { event(.addCompany) }
                Button("Pay by Instructions") { event(.payByInstructions) }
            }
        }
        .padding()
    }
    
    private func lastPaymentView(
        lastPayment: LastPayment
    ) -> some View {
        
        Button(String(describing: lastPayment).prefix(11)) {
            
            event(.select(.lastPayment(lastPayment)))
        }
    }
    
    private func operatorView(
        `operator`: Operator
    ) -> some View {
        
        Button(String(describing: `operator`)/*.prefix(6)*/) {
            
            event(.select(.operator(`operator`)))
        }
    }
}

extension UtilityPrepaymentPickerMockView {
    
    typealias State = UtilityServicePrepaymentState
    typealias Event = UtilityServicePrepaymentEvent
}

struct UtilityPrepaymentPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        
        preview(.preview)
        preview(.empty)
    }
    
    static func preview(
        _ state: UtilityPrepaymentPickerMockView.State
    ) -> some View {
        
        UtilityPrepaymentPickerMockView(
            state: state,
            event: { _ in }
        )
    }
}
