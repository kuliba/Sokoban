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
    let config: Config
    
    var body: some View {
        
        switch state.model {
        case let .field(field):
            fieldView(field, config: config.info)
                .paddedRoundedBackground()
            
        case let .parameter(parameter):
            parameterView(parameter)
            
        case let .widget(widget):
            widgetView(widget)
        }
    }
}

extension AnywayPaymentElementView {
    
    typealias State = AnywayTransactionState.IdentifiedModel
    typealias Event = AnywayPaymentEvent
    typealias Factory = AnywayPaymentElementViewFactory
    typealias Config = AnywayPaymentElementConfig
}

private extension AnywayPaymentElementView {
    
    func fieldView(
        _ field: AnywayElement.UIComponent.Field,
        config: InfoConfig
    ) -> some View {
        
        PaymentComponents.InfoView(
            info: field.info,
            config: config,
            icon: { makeIconView(field) }
        )
    }
    
    func parameterView(
        _ parameter: AnywayElementModel.Parameter
    ) -> some View {
        
        AnywayPaymentParameterView(
            parameter: parameter,
            factory: factory.parameterFactory
        )
    }
    
    func makeIconView(
        _ field: AnywayPaymentDomain.AnywayElement.UIComponent.Field
    ) -> some View {
        
#warning("FIX hardcoded value")
        return factory.makeIconView("placeholder")
    }
    
    @ViewBuilder
    func widgetView(
        _ widget: AnywayElementModel.Widget
    ) -> some View {
        
        switch widget {
        case let .otp(viewModel):
            factory.widgetFactory.makeOTPView(viewModel)
                .paddedRoundedBackground()
                .keyboardType(.numberPad)
            
        case let .simpleOTP(viewModel):
            SimpleOTPWrapperView(viewModel: viewModel)
                .paddedRoundedBackground()
            
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
