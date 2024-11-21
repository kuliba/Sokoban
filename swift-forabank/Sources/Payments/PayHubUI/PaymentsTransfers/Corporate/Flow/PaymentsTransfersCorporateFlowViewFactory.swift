//
//  PaymentsTransfersCorporateFlowViewFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersCorporateFlowViewFactory<ContentView>
where ContentView: View {
    
    public let makeContentView: MakeContentView
    
    public init(
        @ViewBuilder makeContentView: @escaping MakeContentView
    ) {
        self.makeContentView = makeContentView
    }
}

public extension PaymentsTransfersCorporateFlowViewFactory {
    
    typealias MakeContentView = () -> ContentView
}
