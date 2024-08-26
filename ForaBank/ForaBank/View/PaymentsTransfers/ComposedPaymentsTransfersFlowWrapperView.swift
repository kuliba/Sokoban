//
//  ComposedPaymentsTransfersFlowWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersFlowWrapperView: View {
    
    let binder: PaymentsTransfersBinder
    
    var body: some View {
        
        PaymentsTransfersFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                           Text("TBD: makePaymentsTransfersContent(binder.content)")
                        }
                    )
                )
            }
        )
    }
}
