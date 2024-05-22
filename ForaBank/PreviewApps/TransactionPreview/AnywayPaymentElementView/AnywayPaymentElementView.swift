//
//  AnywayPaymentElementView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import SwiftUI

struct AnywayPaymentElementView<IconView: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    #warning("better move config to factory")
    let config: Config
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            PaymentComponents.InfoView(
                info: field.info,
                config: config.info,
                icon: { makeIconView(field) }
            )
            
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
    
    private func makeIconView(
        _ field: AnywayPayment.Element.UIComponent.Field
    ) -> some View {
        
        factory.makeIconView(.field(field))
    }
}

extension AnywayPaymentElementView {
    
    typealias State = AnywayPayment.Element
    typealias Event = AnywayPaymentEvent
    typealias Factory = AnywayPaymentElementViewFactory<IconView>
    typealias Config = AnywayPaymentElementConfig
}

// MARK: - Adapters

private extension AnywayPayment.Element.UIComponent.Field {
    
    var info: PaymentComponents.Info {

        #warning("hardcoded style")
        return .init(id: id, title: title, value: value, style: .expanded)
    }
}

private extension  AnywayPayment.Element.UIComponent.Field {

    var id: PaymentComponents.Info.ID {
        
        switch name {
        case "amount":        return .amount
        case "brandName":     return .brandName
        case "recipientBank": return .recipientBank
        default:              return .other(name)
        }
    }
}

private extension AnywayPayment.Element.UIComponent.Parameter.ID {
    
    var parameterID: AnywayPaymentEvent.ParameterID {
        
        return .init(rawValue)
    }
}

#Preview {
    
    Group {
        
        AnywayPaymentElementView(
            state: .parameter(.stringInput),
            event: { print($0) },
            factory: .preview,
            config: .init(info: .preview)
        )
        
        AnywayPaymentElementView(
            state: .field(.preview),
            event: { print($0) },
            factory: .preview,
            config: .init(info: .preview)
        )
    }
}

private extension AnywayPayment.Element.Field {
    
    static let preview: Self = .init(id: "field name", title: "field title", value: "field value")
}
