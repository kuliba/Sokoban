//
//  PaymentsTransfersFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersFlowViewFactory<ContentView>
where ContentView: View {
    
    public let makeContentView: MakeContentView
    
    public init(
        @ViewBuilder makeContentView: @escaping MakeContentView
    ) {
        self.makeContentView = makeContentView
    }
}

public extension PaymentsTransfersFlowViewFactory {
    
    typealias MakeContentView = () -> ContentView
}
