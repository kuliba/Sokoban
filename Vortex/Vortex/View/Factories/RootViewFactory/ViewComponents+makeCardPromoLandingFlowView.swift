//
//  ViewComponents+makeCardPromoLandingFlowView.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 07.03.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeCardPromoLandingFlowView(
        _ flow: AuthProductsLandingDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            Color.clear
                .navigationLink(
                    value: .init(
                        get: { state.navigation },
                        set: { if $0 == nil { event(.dismiss) }}
                    ),
                    content: { navigation in
                        
                        switch navigation {
                        case let .productID(productID):
                            Text("productID: \(productID)")
                                .frame(maxHeight: .infinity, alignment: .top)
                                .navigationBarWithBack(
                                    title: "Заказать карту",
                                    dismiss: { event(.dismiss) }
                                )
                        }
                    }
                )
        }
    }
}
