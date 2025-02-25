//
//  ViewComponents+makeOrderSavingsAccountCompleteView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeOrderSavingsAccountCompleteView(
        _ orderAccountResponse: OpenSavingsAccountDomain.OrderAccountResponse,
        action: @escaping () -> Void
    ) -> some View {
        
//        OrderSavingsAccountCompleteView(
//            state: orderAccountResponse ? .inflight : .rejected,
//            action: action,
//            makeIconView: makeIconView(md5Hash:)
//        )
        
        Button("goToMain", action: goToMain)
    }
}
