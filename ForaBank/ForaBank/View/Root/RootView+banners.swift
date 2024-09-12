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
        
        switch item {
            
        case let .element(element):
            switch element.element {
                
            case let .banner(banner):
                rootViewFactory.makeIconView(.image(banner.imageEndpoint))
                   /* .resizable()
                    .aspectRatio(contentMode: .fit)*/
                    .frame(width: 288, height: 124)
                    .cornerRadius(12)

            }

        case .placeholder:
            PlaceholderView(opacity: 0.5)
                .frame(.init(width: 288, height: 124))
                ._shimmering()
        }
    }
}

private extension Identified<UUID, BannerCatalogListData> {
    
    var banner: BannerCatalogListData? {
        
        self.element as BannerCatalogListData
    }
}
