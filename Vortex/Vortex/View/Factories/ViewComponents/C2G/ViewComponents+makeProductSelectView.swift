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
        config: ProductSelectConfig = .iVortex,
        edgeInsets: EdgeInsets = .init(top: 13, leading: 16, bottom: 13, trailing: 12)
    ) -> some View {
        
        ProductSelectView(
            state: state,
            event: event,
            config: config,
            cardConfig: config.card.productCardConfig
        )
        .paddedRoundedBackground(edgeInsets: edgeInsets)
    }
}
