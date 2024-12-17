//
//  ProductSelectWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import PaymentComponents
import SwiftUI

struct ProductSelectWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel
    
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

extension ProductSelectWrapperView {
    
    typealias ViewModel = ObservingProductSelectViewModel
    typealias Config = ProductSelectConfig
}
