//
//  ParameterView.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

import SwiftUI

struct ParameterView: View {
    
    let viewModel: ParameterViewModel
    let configuration: OperationViewConfiguration
    let event: (Event.InputEvent) -> Void
    
    init(
        viewModel: ParameterViewModel,
        configuration: OperationViewConfiguration,
        event: @escaping (Event.InputEvent) -> Void
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.event = event
    }
    
    var body: some View {
        
        switch viewModel {
        case let .tip(tipViewModel):
            TipView(
                viewModel: tipViewModel,
                configuration: configuration.tipViewConfig
            )
            
        case let .sticker(stickerViewModel):
            StickerView(
                viewModel: stickerViewModel,
                config: configuration.stickerViewConfig
            )
            
        case let .select(selectViewModel):
            SelectView(
                viewModel: selectViewModel,
                config: .default
            )
            
        case let .product(productViewModel):
            ProductView(
                appearance: configuration.productViewConfig,
                viewModel: productViewModel
            )
            
        case let .amount(amountViewModel):
            AmountView(
                viewModel: amountViewModel,
                configuration: configuration.amountViewConfig,
                text: amountViewModel.parameter.value
            )
        
        case let .input(value, title, error):
            InputView(
                code: value,
                title: title,
                commit: { event(.valueUpdate($0)) },
                warning: error,
                configuration: configuration.inputViewConfig
            )
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
