//
//  RootView+banners.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import Banners
import Combine
import PayHub
import PayHubUI
import SwiftUI
import UIPrimitives

extension RootView {
    
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage
    
    @ViewBuilder
    func makeBannerSectionView(
        bannerPicker: PayHubUI.CorporateBannerPicker
    ) -> some View {
        
        if let binder = bannerPicker.bannerBinder {
            
            makeBannerSectionView(binder: binder)
            
        } else {
            
            Text("Unexpected bannerPicker type \(String(describing: bannerPicker))")
                .foregroundColor(.red)
        }
    }
    
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
                
                let label = rootViewFactory.makeGeneralIconView(.image(item.imageEndpoint))
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
