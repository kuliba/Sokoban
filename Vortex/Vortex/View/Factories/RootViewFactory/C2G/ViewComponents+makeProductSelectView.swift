//
//  ViewComponents+makeProductSelectView.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.02.2025.
//

import SwiftUI
import ProductSelectComponent

extension ViewComponents {
    
    @inlinable
    func makeProductSelectView(
        state: ProductSelect,
        event: @escaping (ProductSelectEvent) -> Void,
        config: ProductSelectConfig = .iVortex
    ) -> some View {
        
        ProductSelectView(
            state: state,
            event: event,
            config: config,
            cardConfig: config.card.productCardConfig
        )
        .paddedRoundedBackground()
    }
}
