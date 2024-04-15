//
//  AnywayPaymentElementView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementView: View {
    
    let state: AnywayPayment.Element
    let event: (AnywayPaymentEvent) -> Void
    // let event: (String) -> Void
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            AnywayPaymentElementFieldView(state: field)
            
        case let .parameter(parameter):
            AnywayPaymentElementParameterView(
                state: parameter,
                event: { event(.setValue($0, for: parameter.id)) }
            )
            
        case let .widget(widget):
            AnywayPaymentElementWidgetView(
                state: widget,
                event: event
            )
        }
    }
}

struct AnywayPaymentElementView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32, content: previewsGroup)
            .padding(.horizontal)
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            anywayPaymentElementView(.field(.preview))
            anywayPaymentElementView(.parameter(.select))
            anywayPaymentElementView(.parameter(.emptyTextInput))
            anywayPaymentElementView(.parameter(.textInput))
            anywayPaymentElementView(.widget(.otp(123)))
        }
    }
    
    static func anywayPaymentElementView(
        _ element: AnywayPayment.Element
    ) -> some View {
        
        AnywayPaymentElementView(state: element, event: { _ in })
    }
}
