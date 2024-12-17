//
//  RootViewFactory+banners.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import Banners
import PayHubUI
import SwiftUI
import UIPrimitives

extension RootViewFactory {
    
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
    
    private func makeBannerSectionView(
        binder: BannerPickerSectionBinder
    ) -> some View {
        
        ComposedBannerPickerSectionFlowView(
            binder: binder,
            config: .init(spacing: 10),
            itemView: itemView,
            makeDestinationView: {
                
                Text(String(describing: $0))
            }
        )
    }
    
    private func itemView(
        item: BannerPickerSectionState.Item
    ) -> some View {
        
        BannerPickerSectionStateItemView(
            item: item,
            config: .iFora,
            bannerView: { item in
                
                let label = makeGeneralIconView(.image(item.imageEndpoint))
                    .frame(Config.iFora.size)
                    .cornerRadius(Config.iFora.cornerRadius)
                
                if isCorporate(),
                   let url = item.orderURL {
                    
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
