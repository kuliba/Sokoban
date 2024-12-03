//
//  RootViewFactory+makeAnywayFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeAnywayFlowView(
        flowModel: AnywayFlowModel
    ) -> some View {
        
        let anywayPaymentFactory = makeAnywayPaymentFactory {
            
            flowModel.state.content.event(.payment($0))
        }
        
        AnywayFlowView(
            flowModel: flowModel,
            factory: .init(
                makeElementView: anywayPaymentFactory.makeElementView,
                makeFooterView: anywayPaymentFactory.makeFooterView
            ),
            makePaymentCompleteView: {
                
                makePaymentCompleteView(
                    .init(
                        formattedAmount: $0.formattedAmount,
                        merchantIcon: $0.merchantIcon,
                        result: $0.result.mapError {
                            
                            return .init(hasExpired: $0.hasExpired)
                        }
                    ),
                    { flowModel.event(.goTo(.main)) }
                )
            }
        )
    }
}
