//
//  RootView+banners.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import SwiftUI
import UIPrimitives
import PayHub
import Combine
import Banners

extension RootView {
    
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage

    func makeBannerSectionView(
        binder: BannerPickerSectionBinder
    ) -> some View {
        
        ComposedBannerPickerSectionFlowView(
            binder: binder,
            config: .init(spacing: 10),
            itemView: itemView,
            makeDestinationView: { Text(String(describing: $0)) }
        )
    }

    @ViewBuilder
    private func itemView(
        item: BannerPickerSectionState.Item
    ) -> some View {
        
        BannerPickerSectionStateItemView(
            item: item,
            config: .iFora,
            bannerView: { item in
                
                let label = rootViewFactory.makeIconView(.image(item.imageEndpoint))
                    .frame(Config.iFora.size)
                    .cornerRadius(Config.iFora.cornerRadius)
                
                if viewModel.model.onlyCorporateCards, let url = item.orderURL {
                    
                    Button { MainViewModel.openLinkURL(url) } label: { label }
                        .buttonStyle(PushButtonStyle())
                        .accessibilityIdentifier("corporateActionBanner")
                } else {
                    label
                }
            },
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
    
    private typealias Config = BannerPickerSectionStateItemViewConfig
}
