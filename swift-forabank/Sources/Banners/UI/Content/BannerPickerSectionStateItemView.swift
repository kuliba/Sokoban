//
//  BannerPickerSectionStateItemView.swift
//  
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import SwiftUI
import PayHub

public protocol ImageLink {
    
    var imageLink: String { get }
}

public struct BannerPickerSectionStateItemImage<BannerIcon, PlaceholderView, ServiceBanner>: View
where BannerIcon: View,
      PlaceholderView: View,
      ServiceBanner: ImageLink {
    
    private let item: Item
    private let config: Config
    private let bannerIcon: (ServiceBanner) -> BannerIcon
    private let placeholderView: () -> PlaceholderView
    
    public init(
        item: Item,
        config: Config,
        bannerIcon: @escaping (ServiceBanner) -> BannerIcon,
        placeholderView: @escaping () -> PlaceholderView
    ) {
        self.item = item
        self.config = config
        self.bannerIcon = bannerIcon
        self.placeholderView = placeholderView
    }
    
    public var body: some View {
        
        switch item {
        case let .element(identified):
            switch identified.element {
            case let .banner(banner):
                bannerView(banner)
            }
            
        case .placeholder:
            placeholderLabel()
        }
    }
}

public extension BannerPickerSectionStateItemImage {
    
    typealias Item = BannerPickerSectionState<ServiceBanner>.Item
    typealias Config = BannerPickerSectionStateItemViewConfig
}

private extension BannerPickerSectionStateItemImage {
    
    func bannerView(
        _ banner: ServiceBanner
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
           /* bannerIcon(banner)
                .frame(config.)
                .renderIconBackground(with: config.iconBackground)
            
            category.name.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)*/
        }
    }
    
    func placeholderLabel() -> some View {
        
        HStack(spacing: 10) {
            
           /* placeholderView()
                .clipShape(RoundedRectangle(
                    cornerRadius: config.placeholder.icon.radius
                ))
                ._shimmering()
                .frame(config.placeholder.icon.size)
            
            placeholderView()
                .clipShape(RoundedRectangle(
                    cornerRadius: config.placeholder.title.radius
                ))
                ._shimmering()
                .frame(config.placeholder.title.size)
                .frame(maxWidth: .infinity, alignment: .leading)*/
        }
    }
}
