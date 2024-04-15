//
//  AnywayPaymentElementParameterView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementParameterView: View {
    
    let state: AnywayPayment.UIComponent.Parameter
    let event: (AnywayPaymentEvent) -> Void
    
    var body: some View {
        
        Text(String(describing: state))
        
        switch state.type {
        case let .select(options):
            Text("TBD: Select with options: \(options)")
            
        case .textInput:
            TextFieldMockView(
                initial: state.value?.rawValue ?? "",
                onChange: { event(.setValue($0, for: state.id)) }
            )
            
        case .unknown:
            EmptyView()
        }
    }
}

struct AnywayPaymentElementParameterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementParameterView(state: .preview, event: { _ in })
    }
}
