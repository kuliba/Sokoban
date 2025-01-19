//
//  RootViewFactory+makePaymentsTransfersSwitcherView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.01.2025.
//

import PayHubUI
import SwiftUI
import UIPrimitives

private extension TimeInterval {
    
    static var refreshCompletionDelay: Self {
        
#if RELEASE
        120
#else
        30
#endif
    }
}

extension RootViewFactory {
    
    func makePaymentsTransfersSwitcherView(
        _ switcher: PaymentsTransfersSwitcher
    ) -> some View {
        
        RefreshableScrollView(
            action: switcher.refresh,
            showsIndicators: false,
            refreshCompletionDelay: .refreshCompletionDelay
        ) {
            ComposedProfileSwitcherView(
                model: switcher,
                corporateView: makePaymentsTransfersCorporateView,
                personalView: makePaymentsTransfersPersonalView,
                undefinedView: { SpinnerView(viewModel: .init()) }
            )
            .padding(.top)
        }
    }
}
