//
//  ViewComponents+makeC2GPaymentCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import PaymentCompletionUI
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteView(
        cover: C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess>
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            // TODO: replace stub with response
            state: cover.completion,
            config: .c2g,
            buttons: { Color.bgIconIndigoLight.frame(height: 92) }
        ) {
            makeSPBFooter(isActive: true, event: goToMain, title: "На главный")
        }
    }
}

private extension C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess> {
    
    var completion: PaymentCompletion {
        
        return .init(
            formattedAmount: "12,345 £",
            merchantIcon: nil,
            status: .inflight
        )
    }
}

#Preview {
    
    ViewComponents.preview.makeC2GPaymentCompleteView(
        cover: .preview
    )
}

private extension C2GPaymentDomain.Navigation.Cover
where Success == Void {
    
    static var preview: Self { .init(id: .init(), success: ()) }
}
