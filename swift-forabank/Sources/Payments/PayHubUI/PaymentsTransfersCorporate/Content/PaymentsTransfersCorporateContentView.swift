//
//  PaymentsTransfersCorporateContentView.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import SwiftUI

public struct PaymentsTransfersCorporateContentView<BannerPicker, BannerSectionView, RestrictionNoticeView, ToolbarView, TransfersSectionView>: View
where BannerSectionView: View,
      RestrictionNoticeView: View,
      ToolbarView: ToolbarContent,
      TransfersSectionView: View {
    
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
            
            VStack(alignment: .leading, spacing: config.spacing) {
                
                factory.makeRestrictionNoticeView()
                
                config.header.render()
                    .padding(.top, config.headerTopPadding)
                
                factory.makeBannerSectionView(content.bannerPicker)
                    .frame(height: config.bannerSectionHeight)
                
                config.title.render()
                    .padding(.top, config.titleTopPadding)
                
                factory.makeTransfersSectionView()
                    .frame(height: config.transfersSectionHeight)
            }
            .padding(config.stack)
        }
        .toolbar(content: factory.makeToolbarView)
    }
}

public extension PaymentsTransfersCorporateContentView {
    
    typealias Content = PaymentsTransfersCorporateContent<BannerPicker>
    typealias Factory = PaymentsTransfersCorporateContentViewFactory<BannerPicker, BannerSectionView, RestrictionNoticeView, ToolbarView, TransfersSectionView>
    typealias Config = PaymentsTransfersCorporateContentViewConfig
}

// MARK: - Previews

#Preview {
    NavigationView {
        
        PaymentsTransfersCorporateContentView(
            content: .preview,
            factory: .init(
                makeBannerSectionView: { (bannerPicker: PreviewBannerPicker) in
                    
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
                },
                makeTransfersSectionView: {
                    
                    ZStack {
                        
                        Color.green.opacity(0.5)
                        
                        Text("Transfers")
                            .foregroundColor(.white)
                            .font(.title3.bold())
                    }
                }
            ),
            config: .preview
        )
    }
    .navigationViewStyle(.stack)
}

private extension PaymentsTransfersCorporateContent
where BannerPicker == PreviewBannerPicker {
    
    static var preview: PaymentsTransfersCorporateContent {
        
        return .init(
            bannerPicker: .init(),
            reload: {}
        )
    }
}

private final class PreviewBannerPicker {}
