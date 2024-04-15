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
                event: event
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
        
        AnywayPaymentElementView(
            state: .widget(.otp(123)),
            event: { _ in }
        )
    }
}
