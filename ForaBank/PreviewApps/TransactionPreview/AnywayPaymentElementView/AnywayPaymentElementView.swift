//
//  AnywayPaymentElementView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentElementView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            AnywayPaymentFieldView(field: field)
            
        case let .parameter(parameter):
            AnywayPaymentParameterView(
                parameter: parameter,
                event: { event(.setValue($0, for: parameter.id.parameterID)) }
            )
            
        case let .widget(widget):
            AnywayPaymentWidgetView(
                widget: widget,
                event: { event(.widget($0)) },
                factory: factory.widget
            )
        }
    }
}

extension AnywayPaymentElementView {
    
    typealias State = AnywayPayment.Element
    typealias Event = AnywayPaymentEvent
    typealias Factory = AnywayPaymentElementViewFactory
}

// MARK: - Adapters

private extension AnywayPayment.Element.UIComponent.Parameter.ID {
    
    var parameterID: AnywayPaymentEvent.ParameterID {
        
        return .init(rawValue)
    }
}

#Preview {
    AnywayPaymentElementView(
        state: .parameter(.stringInput),
        event: { print($0) },
        factory: .preview
    )
}
