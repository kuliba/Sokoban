//
//  ViewComponents+makeC2GPaymentCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import PaymentCompletionUI
import SharedConfigs
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteView(
        cover: C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess>,
        config: C2GPaymentCompleteViewConfig = .iVortex
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: cover.completion,
            statusConfig: .c2g,
            // TODO: replace stub with buttons
            buttons: { Color.bgIconIndigoLight.frame(height: 92) },
            details: { makeC2GPaymentDetailsView(cover: cover, config: config) }
        ) {
            makeSPBFooter(isActive: true, event: goToMain, title: "На главный")
        }
    }
    
    @inlinable
    func makeC2GPaymentDetailsView(
        cover: C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess>,
        config: C2GPaymentCompleteViewConfig
    ) -> some View {
        
        VStack(spacing: config.spacing) {
            
            cover.merchantName.text(withConfig: config.merchantName)
            cover.purpose.text(withConfig: config.purpose)
        }
    }
}

struct C2GPaymentCompleteViewConfig {
    
    let spacing: CGFloat
    let merchantName: TextConfig
    let purpose: TextConfig
}

private extension C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess> {
    
    var completion: PaymentCompletion { // TODO: REPLACE STUBS with real data
        
        return .init(
            formattedAmount: "12,345 £",
            merchantIcon: nil,
            status: .inflight
        )
    }
    
    var merchantName: String { // TODO: REPLACE STUBS with real data
        
        "УФК Владимирской области"
    }
    
    var purpose: String { // TODO: REPLACE STUBS with real data
        
        "Транспортный налог "
    }
}

#Preview {
    
    ViewComponents.preview.makeC2GPaymentCompleteView(
        cover: .preview,
        config: .iVortex
    )
}

private extension C2GPaymentDomain.Navigation.Cover
where Success == Void {
    
    static var preview: Self { .init(id: .init(), success: ()) }
}
