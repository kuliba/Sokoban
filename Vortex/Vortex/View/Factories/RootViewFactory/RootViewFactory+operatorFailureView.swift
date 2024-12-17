//
//  RootViewFactory+operatorFailureView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2024.
//

import FooterComponent
import SwiftUI

extension ViewComponents {
    
    // TODO: - consider grouping, incl. a separate factory(?)
    func operatorFailureView(
        operatorFailure: SberOperatorFailureFlowState<UtilityPaymentProvider>,
        payByInstructions: @escaping () -> Void,
        dismissDestination: @escaping () -> Void
    ) -> some View {
        
        SberOperatorFailureFlowView(
            state: operatorFailure,
            event: dismissDestination,
            contentView: {
                
                FooterView(
                    state: .failure(.iFora),
                    event: { event in
                        
                        switch event {
                        case .payByInstruction:
                            payByInstructions()
                            
                        case .addCompany:
                            break
                        }
                    },
                    config: .iFora
                )
            },
            destinationView: operatorFailureDestinationView
        )
    }
    
    
    @ViewBuilder
    func operatorFailureDestinationView(
        destination: SberOperatorFailureFlowState<UtilityPaymentProvider>.Destination
    ) -> some View {
        
        switch destination {
        case let .payByInstructions(paymentsViewModel):
            makePaymentsView(paymentsViewModel)
                .navigationBarHidden(true)
        }
    }
}
