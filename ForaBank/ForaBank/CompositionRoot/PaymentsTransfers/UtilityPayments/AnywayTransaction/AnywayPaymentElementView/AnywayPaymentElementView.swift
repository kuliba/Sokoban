//
//  AnywayPaymentElementView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
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
        
        switch state.model {
        case let .field(field):
            PaymentComponents.InfoView(
                info: field.info,
                config: config.info,
                icon: { makeIconView(field) }
            )
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

        case let .parameter(parameter):
            AnywayPaymentParameterView(
                parameter: parameter,
                factory: factory.parameterFactory
            )
            
        case let .widget(widget):
            widgetView(widget)
        }
    }
    
    private func makeIconView(
        _ field: AnywayPaymentDomain.AnywayElement.UIComponent.Field
    ) -> some View {
        
        #warning("FIX hardcoded value")
        return factory.makeIconView("placeholder")
    }
}

extension AnywayPaymentElementView {
    
    typealias State = CachedAnywayPayment<AnywayElementModel>.IdentifiedModel
    typealias Event = AnywayPaymentEvent
    typealias Factory = AnywayPaymentElementViewFactory
    typealias Config = AnywayPaymentElementConfig
}

private extension AnywayPaymentElementView {
    
    @ViewBuilder
    func widgetView(
        _ widget: AnywayElementModel.Widget
    ) -> some View {
        
        switch widget {
        case let .otp(viewModel):
            factory.widgetFactory.makeOTPView(viewModel)
            
        case let .simpleOTP(viewModel):
            SimpleOTPWrapperView(viewModel: viewModel)
            
        case let .product(viewModel):
            ProductSelectWrapperView(viewModel: viewModel, config: .iFora)
        }
    }
}

// MARK: - Adapters

private extension AnywayElement.UIComponent.Field {
    
    var info: PaymentComponents.Info {
        
#warning("hardcoded style")
        return .init(id: id, title: title, value: value, style: .expanded)
    }
}

private extension AnywayElement.UIComponent.Field {
    
    var id: PaymentComponents.Info.ID {
        
        switch name {
        case "amount":        return .amount
        case "brandName":     return .brandName
        case "recipientBank": return .recipientBank
        default:              return .other(name)
        }
    }
}
