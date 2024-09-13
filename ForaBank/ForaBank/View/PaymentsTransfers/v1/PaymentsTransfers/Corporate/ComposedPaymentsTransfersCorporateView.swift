//
//  ComposedPaymentsTransfersCorporateView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.09.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersCorporateView<ContentView>: View
where ContentView: View {
    
    let corporate: Corporate
    let factory: Factory
    
    var body: some View {
        
        PaymentsTransfersCorporateFlowWrapperView(
            model: corporate.flow,
            makeContentView: {
                
                PaymentsTransfersCorporateFlowView(
                    state: $0,
                    event: $1,
                    factory: factory
                )
            }
        )
    }
}

extension ComposedPaymentsTransfersCorporateView {
    
    typealias Corporate = PaymentsTransfersCorporate
    typealias Factory = PaymentsTransfersCorporateFlowViewFactory<ContentView>
}
