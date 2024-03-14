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
            detailsState: viewModel.state.detailsState,
            isCheckAccount: $isCheckAccount,
            isCheckCard: $isCheckCard
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text(viewModel.state.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: navigationLeadingItem,
            trailing: navigationTrailingItem
        )
    }
    
    @ViewBuilder
    var navigationLeadingItem: some View {
        
        if viewModel.state.showCheckBox {
            
            Button(action: { viewModel.event(.hideCheckbox) } ) {
                
                Image(systemName: "xmark")
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            
            Button(action: { 
                viewModel.event(.close)
            }) {
                Image(systemName: "chevron.left")
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    var navigationTrailingItem: some View {
        
        Button(action: {
            viewModel.event(.itemTapped(.share))
        }) {
            Image(systemName: "square.and.arrow.up")
            //.foregroundColor(buttonForegroundColor)
        }
        .disabled(buttonDisabled())
    }
    
    private func buttonDisabled() -> Bool {
        
        if viewModel.state.showCheckBox {
            
            return !(isCheckCard || isCheckAccount)
        } else { return false }
    }
}
