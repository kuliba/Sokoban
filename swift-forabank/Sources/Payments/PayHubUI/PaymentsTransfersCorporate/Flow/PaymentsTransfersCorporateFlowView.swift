//
//  PaymentsTransfersCorporateFlowView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersCorporateFlowView<Content>: View
where Content: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let factory: Factory
    
    public init(
        state: State, 
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContentView()
    }
}

public extension PaymentsTransfersCorporateFlowView {
    
    typealias State = PaymentsTransfersCorporateFlowState
    typealias Event = PaymentsTransfersCorporateFlowEvent
    typealias Factory = PaymentsTransfersCorporateFlowViewFactory<Content>
}
