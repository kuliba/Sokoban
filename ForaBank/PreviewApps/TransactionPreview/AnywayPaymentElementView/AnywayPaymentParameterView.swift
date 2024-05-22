//
//  AnywayPaymentParameterView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentParameterView: View {
    
    let parameter: Parameter
    let event: (String) -> Void
    
    var body: some View {
        
        Text("TBD: parameter view")
        
        switch parameter.type {
        case .hidden:
            EmptyView()
            
        case .nonEditable:
            #warning("replace with real components")
            Text("TBD: nonEditable parameter view")
            
        case let .select(option, options):
            #warning("replace with real components")
            Text("TBD: selector")
            
        case .textInput:
            #warning("replace with real components")
            Text("TBD: textInput")
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayPayment.Element.UIComponent.Parameter
}

#Preview {
    AnywayPaymentParameterView(parameter: .textInput, event: { print($0) })
}

private extension AnywayPayment.Element.UIComponent.Parameter {
    
    static let textInput: Self = .init(id: .init(UUID().uuidString), type: .textInput, value: nil)
}
