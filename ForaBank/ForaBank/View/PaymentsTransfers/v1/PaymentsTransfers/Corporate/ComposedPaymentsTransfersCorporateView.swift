//
//  ComposedPaymentsTransfersCorporateView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.09.2024.
//

import PayHub
import PayHubUI
import RxViewModel
import SwiftUI

struct ComposedPaymentsTransfersCorporateView<ContentView, DestinationView, FullScreenCoverView>: View
where ContentView: View,
      DestinationView: View,
      FullScreenCoverView: View {

    let corporate: Corporate
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(
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
    typealias Factory = PaymentsTransfersCorporateFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}
