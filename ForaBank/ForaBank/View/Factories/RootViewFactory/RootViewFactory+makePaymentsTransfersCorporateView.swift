//
//  RootViewFactory+makePaymentsTransfersCorporateView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import SwiftUI

extension RootViewFactory {
    
    func makePaymentsTransfersCorporateView(
        _ corporate: PaymentsTransfersCorporate
    ) -> some View {
        
        ComposedPaymentsTransfersCorporateView(
            corporate: corporate,
            factory: .init(
                makeContentView: {
                    PaymentsTransfersCorporateContentView(
                        content: corporate.content,
                        factory: .init(
                            makeBannerSectionView: makeBannerSectionView,
                            makeRestrictionNoticeView: makeRestrictionNoticeView,
                            makeToolbarView: makePaymentsTransfersCorporateToolbarView,
                            makeTransfersSectionView: makeTransfersSectionView
                        ),
                        config: .iFora
                    )
                },
                makeFullScreenCoverView: { _ in
                    
                    Text("TBD: FullScreenCoverView")
                },
                makeDestinationView: { _ in
                    
                    Text("TBD: DestinationView")
                }
            )
        )
    }
    
    private func makeRestrictionNoticeView() -> some View {
        
        DisableCorCardsView(text: .disableForCorCards)
    }
    
    private func makePaymentsTransfersCorporateToolbarView() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            
            HStack {
                
                Image(systemName: "person")
                Text("TBD: Profile without QR")
            }
        }
    }
    
    private func makeTransfersSectionView() -> some View {
        
        ZStack {
            
            Color.green.opacity(0.5)
            
            Text("Transfers")
                .foregroundColor(.white)
                .font(.title3.bold())
        }
    }
}
