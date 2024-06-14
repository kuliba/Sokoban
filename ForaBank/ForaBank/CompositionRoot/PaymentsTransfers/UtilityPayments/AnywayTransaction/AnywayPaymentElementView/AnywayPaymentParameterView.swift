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
        
        switch parameter {
        case .hidden:
            EmptyView()
            
        case .nonEditable:
#warning("replace with real components")
            Text("TBD: nonEditable parameter view")
            
        case let .numberInput(viewModel):
#warning("replace with specific number input view")
            InputWrapperView(
                viewModel: viewModel,
                makeIconView: {
                    
                    factory.makeIconView(viewModel.state.settings.icon)
                        .frame(width: 32, height: 32)
                }
            )
            
        case let .select(selectViewModel):
            factory.makeSelectView(selectViewModel)
            
        case let .textInput(viewModel):
            InputWrapperView(
                viewModel: viewModel,
                makeIconView: {
                    
                    factory.makeIconView(viewModel.state.settings.icon)
                        .frame(width: 32, height: 32)
                }
            )
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayElementModel.Parameter
    typealias Factory = AnywayPaymentParameterViewFactory
}
