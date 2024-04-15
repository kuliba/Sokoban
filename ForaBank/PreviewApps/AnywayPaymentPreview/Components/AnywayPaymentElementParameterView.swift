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
    let event: (String) -> Void
    
    var body: some View {
        
        switch state.type {
        case let .select(options):
            Text("TBD: Select with options: \(options)")
            
        case .textInput:
            TextFieldMockWrapperView(
                initial: state.value?.rawValue ?? "",
                onChange: event
            )
            
        case .unknown:
            EmptyView()
        }
    }
}

struct AnywayPaymentElementParameterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32, content: previewsGroup)
            .padding(.horizontal)
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            anywayPaymentElementParameterView(.select)
            anywayPaymentElementParameterView(.emptyTextInput)
            anywayPaymentElementParameterView(.textInput)
        }
    }
    
    static func anywayPaymentElementParameterView(
        _ parameter: AnywayPayment.Element.Parameter
    ) -> some View {
        
        AnywayPaymentElementParameterView(state: parameter.uiComponent, event: { _ in })
    }
}
