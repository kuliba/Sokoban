//
//  ComposedPaymentsTransfersPersonalView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersPersonalView<ContentView>: View
where ContentView: View {
    
    let personal: Personal
    let factory: Factory
    
    var body: some View {
        
        PaymentsTransfersPersonalFlowWrapperView(
            model: personal.flow,
            makeContentView: {
                
                PaymentsTransfersPersonalFlowView(
                    state: $0,
                    event: $1,
                    factory: factory
                )
            }
        )
    }
}

extension ComposedPaymentsTransfersPersonalView {
    
    typealias Personal = PaymentsTransfersPersonal
    typealias Factory = PaymentsTransfersPersonalFlowViewFactory<ContentView>
}
