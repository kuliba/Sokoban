//
//  ParameterView.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

import SwiftUI

struct ParameterView: View {
    
    let viewModel: ParameterViewModel
    
    var body: some View {
        
        switch viewModel {
        case let .tip(tipViewModel):
            TipView(viewModel: tipViewModel)
            
        case let .sticker(stickerViewModel):
            StickerView(
                viewModel: stickerViewModel,
                openAccountCardView: {
                    
                    Color.red
                        .frame(width: 120)
                    
                },
                config: .default
            )
            
        case let .select(selectViewModel):
            SelectView(
                viewModel: selectViewModel,
                config: .default
            )
            
        case let .product(productViewModel):
            ProductView(
                appearance: .default,
                viewModel: productViewModel
            )
            
        case let .amount(amountViewModel):
            AmountView(
                viewModel: .init(
                    parameter: .init(
                        value: amountViewModel.parameter.value
                    ),
                    continueButtonTapped: amountViewModel.continueButtonTapped
                ),
                text: amountViewModel.parameter.value
            )
        
        case let .input(inputViewModel):
            InputView(model: inputViewModel)
        }
    }
}

struct ParameterView_Previews: PreviewProvider {
    static var previews: some View {
       
        #warning("add previews")
        // ParameterView()
        EmptyView()
    }
}
