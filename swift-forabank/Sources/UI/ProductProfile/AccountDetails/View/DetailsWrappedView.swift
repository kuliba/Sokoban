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
    
    @State private var isCheck = false

    private let config: Config
    private let title: String
    private let showCheckbox: Bool

    public init(
        viewModel: ProductDetailsViewModel,
        config: Config,
        title: String,
        showCheckbox: Bool
    ) {
        self.viewModel = viewModel
        self.config = config
        self.title = title
        self.showCheckbox = showCheckbox
    }

    public var body: some View {
        
        ProductDetailsView(
            items: viewModel.state.items,
            event: { viewModel.event(.itemTapped($0)) },
            config: config,
            title: title,
            showCheckbox: showCheckbox,
            isCheck: $isCheck
        )
    }
}
