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

    private func itemView(
        item: BannerPickerSectionState.Item
    ) -> some View {
        
        BannerPickerSectionStateItemView(
            item: item, 
            event: {
                
                if viewModel.model.onlyCorporateCards, 
                    case let .select(item) = $0,
                    let url = item?.orderURL {
                    
                    MainViewModel.openLinkURL(url)
                }
            },
            config: .iFora,
            bannerView: { rootViewFactory.makeIconView(.image($0.imageEndpoint)) },
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
}
