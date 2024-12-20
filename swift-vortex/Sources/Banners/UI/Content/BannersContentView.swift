//
//  BannersContentView.swift
//
//
//  Created by Andryusina Nataly on 17.09.2024.
//

import SwiftUI

public struct BannersContentView<BannerPicker, BannerSectionView>: View
where BannerSectionView: View {
    
    @ObservedObject private var content: Content
    
    let factory: Factory
    let config: Config
    
    public init(
        content: Content,
        factory: Factory,
        config: Config
    ) {
        self.content = content
        self.factory = factory
        self.config = config
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            factory.makeBannerSectionView(content.bannerPicker)
                .frame(height: config.bannerSectionHeight)
        }
    }
}

public extension BannersContentView {
    
    typealias Content = BannersContent<BannerPicker>
    typealias Factory = BannersContentViewFactory<BannerPicker, BannerSectionView>
    typealias Config = BannersContentViewConfig
}

// MARK: - Previews

#Preview {
    NavigationView {
        
        BannersContentView(
            content: .preview,
            factory: .init(
                makeBannerSectionView: { (bannerPicker: PreviewBannerPicker) in
                    
                    ZStack {
                        
                        Color.orange.opacity(0.5)
                        
                        Text("Banners")
                            .foregroundColor(.white)
                            .font(.title3.bold())
                    }
                }
            ),
            config: .init(bannerSectionHeight: 120, spacing: 10)
        )
    }
    .navigationViewStyle(.stack)
}

private extension BannersContent
where BannerPicker == PreviewBannerPicker {
    
    static var preview: BannersContent {
        
        return .init(
            bannerPicker: .init(),
            reload: {}
        )
    }
}

private final class PreviewBannerPicker {}
