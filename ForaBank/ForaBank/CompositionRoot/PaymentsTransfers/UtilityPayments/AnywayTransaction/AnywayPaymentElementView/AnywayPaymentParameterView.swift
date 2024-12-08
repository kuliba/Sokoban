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
        case .hidden:
            EmptyView()
            
        case let .nonEditable(node):
            inputView(keyboard: .decimal, model: node.model)
                .disabled(true)
            
        case let .numberInput(node):
            inputView(keyboard: .decimal, model: node.model)
            
        case let .select(viewModel):
            factory.makeSelectorView(parameter, viewModel)
                .paddedRoundedBackground()
            
        case let .textInput(node):
            inputView(keyboard: .default, model: node.model)
            
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
        keyboard: TextFieldUI.KeyboardType,
        model: RxInputViewModel
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
}
