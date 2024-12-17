//
//  ProductSelectStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import PaymentComponents
import SwiftUI

struct ProductSelectStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(
        viewModel: ViewModel,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    let config: Config
    
    var body: some View {
        
        ProductSelectView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: config,
            cardConfig: config.card.productCardConfig
        )
    }
}

extension ProductSelectStateWrapperView {
    
    typealias ViewModel = ObservingProductSelectViewModel
    typealias Config = ProductSelectConfig
}
