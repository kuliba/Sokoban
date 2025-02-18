//
//  ViewComponents+makeC2GPaymentCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteView(
        cover: C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess>,
        goToMain: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text("TBD: Success Screen")
                .font(.headline)
            
            Button("GO TO MAIN", action: goToMain)
        }
    }
}
