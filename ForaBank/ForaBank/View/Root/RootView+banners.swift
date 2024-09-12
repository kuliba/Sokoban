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

    func makeBannerPickerSectionView(
        binder: BannerPickerSectionBinder
    ) -> some View {
        
        ComposedBannerPickerSectionFlowView(
            binder: binder,
            config: .init(spacing: 10),
            itemView: itemView,
            makeDestinationView: {_ in return EmptyView()}
        )
    }

    private func itemView(
        item: BannerPickerSectionState.Item
    ) -> some View {
        
        switch item {
            
        case let .element(element):
            switch element.element {
                
            case let .banner(banner):
                rootViewFactory.makeIconView(.image(banner.imageEndpoint))

            case .showAll:
                UIPrimitives.AsyncImage.init(
                    image: .cardPlaceholder,
                    publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
    )
            }

        case .placeholder:
            UIPrimitives.AsyncImage.init(
                image: .cardPlaceholder,
                publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
)
        }
    }
}

private extension Identified<UUID, BannerCatalogListData> {
    
    var banner: BannerCatalogListData? {
        
        self.element as BannerCatalogListData
    }
}
