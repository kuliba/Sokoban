//
//  ComposedPaymentsTransfersTransfersView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.11.2024.
//

import RxViewModel
import SwiftUI

struct ComposedPaymentsTransfersTransfersView<ContentView>: View
where ContentView: View {
    
    let flow: Flow
    let contentView: () -> ContentView
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(model: flow) {
            
            PaymentsTransfersPersonalTransfersFlowView(
                state: $0,
                event: $1,
                contentView: contentView,
                viewFactory: factory
            )
        }
    }
}

extension ComposedPaymentsTransfersTransfersView {
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
    typealias Flow = Domain.FlowDomain.Flow
    typealias Factory = PaymentsTransfersPersonalTransfersFlowViewFactory
}
