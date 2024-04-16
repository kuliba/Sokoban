//
//  AnywayPaymentElementView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementView<FieldView, ParameterView, WidgetView>: View
where FieldView: View,
      ParameterView: View,
      WidgetView: View {
    
    let state: AnywayPayment.Element
    let event: (AnywayPaymentEvent) -> Void
    let factory: AnywayPaymentElementViewFactory<FieldView, ParameterView, WidgetView>
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            factory.fieldView(field)
            
        case let .parameter(parameter):
            factory.parameterView(
                parameter,
                { event(.setValue($0, for: parameter.id)) }
            )
            
        case let .widget(widget):
            factory.widgetView(
                widget,
                { event(.widget($0)) }
            )
        }
    }
}

struct AnywayPaymentElementViewFactory<FieldView, ParameterView, WidgetView> {
    
    let fieldView: (Field) -> FieldView
    let parameterView: (Parameter, @escaping (String) -> Void) -> ParameterView
    let widgetView: (Widget, @escaping (AnywayPaymentEvent.Widget) -> Void) -> WidgetView
}

extension AnywayPaymentElementViewFactory {
    
    typealias Field = AnywayPayment.UIComponent.Field
    typealias Parameter = AnywayPayment.UIComponent.Parameter
    typealias Widget = AnywayPayment.UIComponent.Widget
}

extension AnywayPaymentElementViewFactory
where FieldView == AnywayPaymentElementFieldView,
      ParameterView == AnywayPaymentElementParameterView,
      WidgetView == AnywayPaymentElementWidgetView<OTPMockView, Text> {
    
    static var preview: Self {
        
        .init(
            fieldView: FieldView.init,
            parameterView: ParameterView.init,
            widgetView: { .init(state: $0, event: $1, factory: .preview) }
        )
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
        
        AnywayPaymentElementView(
            state: element,
            event: { _ in },
            factory: .preview
        )
    }
}
