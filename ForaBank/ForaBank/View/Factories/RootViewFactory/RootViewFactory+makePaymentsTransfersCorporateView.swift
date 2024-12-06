//
//  RootViewFactory+makePaymentsTransfersCorporateView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
    func makePaymentsTransfersCorporateView(
        _ binder: PaymentsTransfersCorporateDomain.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersCorporateFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                            makePaymentsTransfersCorporateContentView(binder)
                        },
                        makeFullScreenCoverView: makeFullScreenCoverView,
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
    }
    
    private func makePaymentsTransfersCorporateContentView(
        _ binder: PaymentsTransfersCorporateDomain.Binder
    ) -> some View {
        
        PaymentsTransfersCorporateContentView(
            content: binder.content,
            factory: .init(
                makeBannerSectionView: makeBannerSectionView,
                makeRestrictionNoticeView: makeRestrictionNoticeView,
                makeToolbarView: {
                    
                    makePaymentsTransfersCorporateToolbarView(binder)
                },
                makeTransfersSectionView: makeTransfersSectionView
            ),
            config: .iFora
        )
    }
    
    private func makeRestrictionNoticeView() -> some View {
        
        DisableCorCardsView(text: .disableForCorCards)
    }
    
    private func makePaymentsTransfersCorporateToolbarView(
        _ binder: PaymentsTransfersCorporateDomain.Binder
    ) -> some ToolbarContent {
        
        makeUserAccountToolbarButton {
            
            binder.flow.event(.select(.userAccount))
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
    
    private func makeDestinationView(
        destination: PaymentsTransfersCorporateNavigation.Destination
    ) -> some View {
        
        Text("TBD: DestinationView")
    }
    
    private func makeFullScreenCoverView(
        fullScreenCover: PaymentsTransfersCorporateNavigation.FullScreenCover
    ) -> some View {
        
        Text("TBD: FullScreenCoverView")
    }
}
