//
//  ProductSelectStateWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import PaymentComponents
import RxViewModel
import SwiftUI

typealias ObservingProductSelectViewModel = RxObservingViewModel<ProductSelect, ProductSelectEvent, Never>

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

#Preview {
    ProductSelectStateWrapperView(viewModel: .preview(), config: .preview)
}
