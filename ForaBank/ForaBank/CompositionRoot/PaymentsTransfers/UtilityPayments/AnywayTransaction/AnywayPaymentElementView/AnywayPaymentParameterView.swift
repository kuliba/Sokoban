//
//  AnywayPaymentParameterView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI

struct AnywayPaymentParameterView: View {
    
    let parameter: Parameter
    let factory: Factory
    
    var body: some View {
        
        switch parameter.type {
        case .hidden:
            EmptyView()
            
        case .nonEditable:
#warning("replace with real components")
            Text("TBD: nonEditable parameter view")
            
        case let .numberInput(viewModel):
            TextInputWrapperView(
                model: viewModel,
                config: .iFora(
                    keyboard: .decimal, 
                    title: parameter.origin.title
                ),
                iconView: {
                    
                    factory.makeIconView(parameter.origin.icon)
                        .frame(width: 32, height: 32)
                }
            )
            .paddedRoundedBackground()
            
        case let .select(viewModel):
            factory.makeSelectorView(viewModel)
                .paddedRoundedBackground()
            
        case let .textInput(viewModel):
            TextInputWrapperView(
                model: viewModel,
                config: .iFora(
                    keyboard: .default,
                    title: parameter.origin.title
                ),
                iconView: {
                    
                    factory.makeIconView(parameter.origin.icon)
                        .frame(width: 32, height: 32)
                }
            )
            .paddedRoundedBackground()
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayElementModel.Parameter
    typealias Factory = AnywayPaymentParameterViewFactory
}
