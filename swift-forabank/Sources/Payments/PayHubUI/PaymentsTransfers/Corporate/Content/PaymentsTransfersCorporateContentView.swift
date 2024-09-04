//
//  PaymentsTransfersCorporateContentView.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import SwiftUI

public struct PaymentsTransfersCorporateContentView<BannerSectionView, RestrictionNoticeView, ToolbarView>: View
where BannerSectionView: View,
      RestrictionNoticeView: View,
      ToolbarView: ToolbarContent {
    
    let content: Content
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
            
            VStack(alignment: .leading, spacing: config.spacing) {
                
                factory.makeRestrictionNoticeView()
                
                config.header.render()
                    .padding(.top, config.headerTopPadding)
                
                factory.makeBannerSectionView()
                    .frame(height: config.bannerSectionHeight)
                
                config.title.render()
                    .padding(.top, config.titleTopPadding)
                
                Text("TBD " + String(describing: content))
            }
            .padding(config.stack)
        }
        .toolbar(content: factory.makeToolbarView)
    }
}

public extension PaymentsTransfersCorporateContentView {
    
    typealias Content = PaymentsTransfersCorporateContent
    typealias Factory = PaymentsTransfersCorporateContentViewFactory<BannerSectionView, RestrictionNoticeView, ToolbarView>
    typealias Config = PaymentsTransfersCorporateContentViewConfig
}

// MARK: - Previews

#Preview {
    NavigationView {
        
        PaymentsTransfersCorporateContentView(
            content: .init(),
            factory: .init(
                makeBannerSectionView: {
                    
                    ZStack {
                        
                        Color.orange.opacity(0.5)
                        
                        Text("Banners")
                            .foregroundColor(.white)
                            .font(.title3.bold())
                    }
                },
                makeRestrictionNoticeView: {
                    
                    Text("App functionality is restricted")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                },
                makeToolbarView: {
                    
                    ToolbarItem(placement: .topBarLeading) {
                        
                        HStack {
                            
                            Image(systemName: "person")
                            Text("TBD: Profile without QR")
                        }
                    }
                }
            ),
            config: .preview
        )
    }
    .navigationViewStyle(.stack)
}
