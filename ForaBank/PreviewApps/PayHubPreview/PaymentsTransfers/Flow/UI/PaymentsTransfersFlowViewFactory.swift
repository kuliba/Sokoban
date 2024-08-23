//
//  PaymentsTransfersFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct PaymentsTransfersFlowViewFactory<ContentView>
where ContentView: View {
    
    @ViewBuilder let makeContentView: MakeContentView
}

extension PaymentsTransfersFlowViewFactory {
    
    typealias MakeContentView = () -> ContentView
}
