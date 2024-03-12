//
//  ProductDetailsWrappedView.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias ProductDetailsViewModel = RxViewModel<ProductDetailsState, ProductDetailsEvent, ProductDetailsEffect>

public struct ProductDetailsWrappedView: View {
    
    @ObservedObject private var viewModel: ProductDetailsViewModel
    
    @State private var isCheckAccount = false
    @State private var isCheckCard = false
    
    private let config: Config
    
    public init(
        viewModel: ProductDetailsViewModel,
        config: Config
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        ProductDetailsView(
            accountDetails: viewModel.state.accountDetails,
            cardDetails: viewModel.state.cardDetails,
            event: { viewModel.event(.itemTapped($0)) },
            config: config,
            showCheckbox: viewModel.state.showCheckBox,
            isCheckAccount: $isCheckAccount,
            isCheckCard: $isCheckCard
        )
    }
}
