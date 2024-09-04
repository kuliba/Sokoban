//
//  PaymentsTransfersPersonalFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersPersonalFlowView<Content>: View
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

public extension PaymentsTransfersPersonalFlowView {
    
    typealias State = PaymentsTransfersPersonalFlowState
    typealias Event = PaymentsTransfersPersonalFlowEvent
    typealias Factory = PaymentsTransfersPersonalFlowViewFactory<Content>
}
