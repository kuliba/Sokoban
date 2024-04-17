//
//  ProductSelectView+ext.swift
//
//
//  Created by Igor Malyarov on 17.04.2024.
//

import SwiftUI

public extension ProductSelectView where ProductView == ProductCardView {
    
    init(
        state: ProductSelect,
        event: @escaping (ProductSelectEvent) -> Void,
        config: ProductSelectConfig,
        cardConfig: ProductCardConfig
    ) {
        self.init(
            state: state,
            event: event,
            config: config,
            productView: {
                
                .init(
                    productCard: .init(product: $0),
                    config: cardConfig
                )
            }
        )
    }
}
