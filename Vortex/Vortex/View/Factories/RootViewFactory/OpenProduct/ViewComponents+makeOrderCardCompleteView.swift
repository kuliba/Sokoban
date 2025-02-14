//
//  ViewComponents+makeOrderCardCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeOrderCardCompleteView(
        _ orderCardResponse: OpenCardDomain.OrderCardResponse,
        action: @escaping () -> Void
    ) -> some View {
        
        OrderCardCompleteView(
            state: orderCardResponse ? .inflight : .rejected,
            action: action,
            makeIconView: makeIconView(md5Hash:)
        )
    }
}
