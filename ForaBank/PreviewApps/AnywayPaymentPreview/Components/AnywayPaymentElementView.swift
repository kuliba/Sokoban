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
    
    let fieldView: (Field) -> FieldView
    let parameterView: (Parameter, @escaping (String) -> Void) -> ParameterView
    let widgetView: (Widget, @escaping (AnywayPaymentEvent.Widget) -> Void) -> WidgetView
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            fieldView(field)
            
        case let .parameter(parameter):
            parameterView(
                parameter,
                { event(.setValue($0, for: parameter.id)) }
            )
            
        case let .widget(widget):
            widgetView(
                widget,
                { event(.widget($0)) }
            )
        }
    }
}

extension AnywayPaymentElementView {
    
   typealias Field = AnywayPayment.UIComponent.Field
   typealias Parameter = AnywayPayment.UIComponent.Parameter
   typealias Widget = AnywayPayment.UIComponent.Widget
}

extension AnywayPaymentElementView
where FieldView == AnywayPaymentElementFieldView,
      ParameterView == AnywayPaymentElementParameterView,
      WidgetView == AnywayPaymentElementWidgetView {
    
    init(
        state: AnywayPayment.Element,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) {
        self.init(
            state: state,
            event: event,
            fieldView: AnywayPaymentElementFieldView.init,
            parameterView: ParameterView.init,
            widgetView: WidgetView.init
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
        
        AnywayPaymentElementView(state: element, event: { _ in })
    }
}
