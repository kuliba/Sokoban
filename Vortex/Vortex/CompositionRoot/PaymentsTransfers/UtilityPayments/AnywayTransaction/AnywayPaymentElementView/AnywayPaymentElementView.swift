//
//  AnywayPaymentElementView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import PaymentComponents
import SwiftUI
import TextFieldUI

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
            
        case let .withContacts(withContacts):
            withContactsView(withContacts)
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
            icon: { factory.makeIconView(field.icon) }
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
    
    @ViewBuilder
    func widgetView(
        _ widget: AnywayElementModel.Widget
    ) -> some View {
        
        switch widget {
        case let .info(info):
            AnywayInfoView(fields: info.fields, config: .iVortex)
                .paddedRoundedBackground()
            
        case let .otp(viewModel):
            factory.widgetFactory.makeOTPView(viewModel)
                .paddedRoundedBackground()
                .keyboardType(.numberPad)
            
        case let .simpleOTP(viewModel):
            SimpleOTPWrapperView(viewModel: viewModel)
                .paddedRoundedBackground()
            
        case let .product(viewModel):
            ProductSelectWrapperView(viewModel: viewModel, config: .iVortex)
                .paddedRoundedBackground()
        }
    }
    
    private var keyboard: TextFieldUI.KeyboardType { .default }
    
    func withContactsView(
        _ withContacts: AnywayElementModel.WithContacts
    ) -> some View {
        
        WithContactView(
            withContacts: withContacts,
            makeTextInputWrapperView: {
                
                TextInputWrapperView(
                    model: $0.input.model,
                    config: .iVortex(
                        keyboard: keyboard,
                        title: $0.origin.title
                    ),
                    iconView: {
                        
                        factory.makeIconView(withContacts.origin.icon)
                            .frame(width: 32, height: 32)
                    }
                )
            }, 
            makeContactsView: factory.makeContactsView
        )
         .paddedRoundedBackground()
    }
}

struct WithContactView<InputView: View, ContactsView: View>: View {
    
    @State private var isShowingContacts = false
    
    let withContacts: AnywayElementModel.WithContacts
    let makeTextInputWrapperView: (AnywayElementModel.WithContacts) -> InputView
    let makeContactsView: (ContactsViewModel) -> ContactsView
    
    var body: some View {
        
        HStack {
            
            makeTextInputWrapperView(withContacts)
            
            Button {
                isShowingContacts = true
            } label: {
                Image.ic24User
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isShowingContacts) {
            
            makeContactsView(withContacts.contacts)
                .onReceive(withContacts.contacts.phoneDigitsPublisher) { _ in
                    
                    isShowingContacts = false
                }
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
