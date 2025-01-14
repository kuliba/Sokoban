//
//  AnywayPaymentParameterView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI
import TextFieldUI

struct AnywayPaymentParameterView: View {
    
    let parameter: Parameter
    let factory: Factory
    
    var body: some View {
        
        switch parameter.type {
        case let .checkbox(node):
            checkboxView(node.model)
            
        case .hidden:
            EmptyView()
            
        case let .nonEditable(node):
            inputView(model: node.model)
                .disabled(true)
            
        case let .numberInput(node):
            inputView(model: node.model, keyboard: .decimal)
            
        case let .select(viewModel):
            factory.makeSelectorView(parameter, viewModel)
                .paddedRoundedBackground()
            
        case let .textInput(node):
            inputView(model: node.model, keyboard: .default)
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayElementModel.Parameter
    typealias Factory = AnywayPaymentParameterViewFactory
}

private extension AnywayPaymentParameterView {
    
    func inputView(
        model: RxInputViewModel,
        keyboard: TextFieldUI.KeyboardType = .default
    ) -> some View {
        
        TextInputWrapperView(
            model: model,
            config: .iVortex(
                keyboard: keyboard,
                title: parameter.origin.title
            ),
            iconView: {
                
                factory.makeIconView(parameter.origin.icon)
                    .frame(width: 32, height: 32)
            }
        )
        .paddedRoundedBackground()
    }
    
    func checkboxView(
        _ model: RxCheckboxViewModel
    ) -> some View {
        
        RxWrapperView(
            model: model
        ) { state, event in
            
            HStack(alignment: .top, spacing: 18) {
                
                PaymentsCheckView.CheckBoxView(
                    isChecked: .init(
                        get: { state.isChecked },
                        set: { _ in event(.toggle) }
                    ),
                    activeColor: .systemColorActive
                )
                
                Text(state.text)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .animation(.easeInOut, value: state.isChecked)
            .contentShape(Rectangle())
            .onTapGesture { event(.toggle) }
        }
    }
}
