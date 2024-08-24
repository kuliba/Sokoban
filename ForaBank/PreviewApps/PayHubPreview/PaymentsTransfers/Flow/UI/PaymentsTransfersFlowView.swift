//
//  PaymentsTransfersFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

struct PaymentsTransfersFlowView<Content>: View
where Content: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        factory.makeContentView()
    }
}

extension PaymentsTransfersFlowView {
    
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias Factory = PaymentsTransfersFlowViewFactory<Content>
}
