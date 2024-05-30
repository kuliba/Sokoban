//
//  ComposedAnywayPaymentView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import SwiftUI

struct ComposedAnywayPaymentView<FieldView, OTPView, ParameterView, ProductPicker>: View
where FieldView: View,
      OTPView: View,
      ParameterView: View,
      ProductPicker: View {
    
    let buttonTitle: String
    let elements: [AnywayPayment.Element]
    let isEnabled: Bool
    let event: (AnywayPaymentEvent) -> Void
    let config: AnywayPaymentFooterConfig
    
    let factory: ComposedAnywayPaymentViewFactory<FieldView, OTPView, ParameterView, ProductPicker>
    
    var body: some View {
        
        AnywayPaymentLayoutView(
            elements: elements,
            elementView: elementView,
            footerView: footerView
        )
    }
    
    private func elementView(
        state: AnywayPayment.Element
    ) -> some View {
        
        AnywayPaymentElementView(
            state: state,
            event: event,
            factory: .init(
                fieldView: factory.fieldView,
                parameterView: factory.parameterView,
                widgetView: widgetView
            )
        )
    }
    
    private func widgetView(
        state: AnywayPayment.Element.UIComponent.Widget,
        event: @escaping (AnywayPaymentEvent.Widget) -> Void
    ) -> some View {
        
        AnywayPaymentElementWidgetView(
            state: state,
            event: event,
            factory: .init(
                otpView: factory.otpView,
                productPicker: factory.productPicker
            )
        )
    }
    
    private func footerView() -> some View {
        
        AnywayPaymentFooterView(
            state: .init(
                buttonTitle: buttonTitle,
                core: elements.core,
                isEnabled: isEnabled
            ),
            event: { footerEvent in
                
                switch footerEvent {
                case let .edit(decimal):
                    event(.widget(.amount(decimal)))
                    
                case .continue:
                    print("Continue is a higher level event")
                }
            },
            config: config
        )
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    var core: AnywayPaymentFooter.Core? {
        
        guard case let .widget(.core(core)) = self[id: .widgetID(.core)]
        else { return nil }
        
        return .init(value: core.amount, currency: core.currency.rawValue)
    }
}

struct ComposedAnywayPaymentLayoutView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ComposedAnywayPaymentView(
            buttonTitle: "Continue",
            elements: .preview,
            isEnabled: true,
            event: { _ in },
            config: .preview,
            factory: .preview
        )
    }
}
