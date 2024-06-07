//
//  AnywayPaymentElementView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentElementView<FieldView, ParameterView, WidgetView>: View
where FieldView: View,
      ParameterView: View,
      WidgetView: View {
    
    let state: AnywayPayment.AnywayElement
    let event: (AnywayPaymentEvent) -> Void
    let factory: AnywayPaymentElementViewFactory<FieldView, ParameterView, WidgetView>
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            factory.fieldView(field)
            
        case let .parameter(parameter):
            factory.parameterView(
                parameter,
                { event(.setValue($0, for: parameter.id.parameterID)) }
            )
            
        case let .widget(widget):
            factory.widgetView(
                widget,
                { event(.widget($0)) }
            )
        }
    }
}

// MARK: - Adapters
private extension AnywayPayment.AnywayElement.UIComponent.Parameter.ID {
    
    var parameterID: AnywayPaymentEvent.ParameterID {
    
        return .init(rawValue)
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
        _ element: AnywayPayment.AnywayElement
    ) -> some View {
        
        AnywayPaymentElementView(
            state: element,
            event: { _ in },
            factory: .preview
        )
    }
}
