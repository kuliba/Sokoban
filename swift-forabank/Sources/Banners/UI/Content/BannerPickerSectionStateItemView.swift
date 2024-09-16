//
//  BannerPickerSectionStateItemView.swift
//
//
//  Created by Andryusina Nataly on 13.09.2024.
//

import SwiftUI
import PayHub

public struct BannerPickerSectionStateItemView<BannerView, PlaceholderView, ServiceBanner>: View
where BannerView: View,
      PlaceholderView: View {
    
    private let item: Item
    private let event: (Event) -> Void
    private let config: Config
    private let bannerView: (ServiceBanner) -> BannerView
    private let placeholderView: () -> PlaceholderView
    
    public init(
        item: Item,
        event: @escaping (Event) -> Void,
        config: Config,
        bannerView: @escaping (ServiceBanner) -> BannerView,
        placeholderView: @escaping () -> PlaceholderView
    ) {
        self.item = item
        self.event = event
        self.config = config
        self.bannerView = bannerView
        self.placeholderView = placeholderView
    }
    
    public var body: some View {
        
        switch item {
        case let .element(identified):
            switch identified.element {
            case let .banner(banner):
                Button(
                    action: { event(.select(banner)) },
                    label: {
                        bannerView(banner)
                            .modifier(FrameWithCornerRadiusModifier(config: config))
                    })
            }
            
        case .placeholder:
            placeholderView()
                .modifier(FrameWithCornerRadiusModifier(config: config))
                ._shimmering()
        }
    }
}

public extension BannerPickerSectionStateItemView {
    
    typealias Item = BannerPickerSectionState<ServiceBanner>.Item
    typealias Config = BannerPickerSectionStateItemViewConfig
    typealias Event = LoadablePickerEvent<ServiceBanner>
}

private struct FrameWithCornerRadiusModifier: ViewModifier {
    
    let config: BannerPickerSectionStateItemViewConfig
    
    func body(content: Content) -> some View {
        content
            .frame(config.size)
            .cornerRadius(config.cornerRadius)
    }
}

