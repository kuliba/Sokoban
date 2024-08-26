//
//  PaymentsTransfersFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersFlowWrapperView<FlowView>: View
where FlowView: View {
    
    @ObservedObject private var model: Model
    
    private let makeFlowView: MakeFlowView
    
    public init(
        model: Model,
        makeFlowView: @escaping MakeFlowView
    ) {
        self._model = .init(wrappedValue: model)
        self.makeFlowView = makeFlowView
    }
    
    public var body: some View {
        
        makeFlowView(model.state, model.event(_:))
    }
}

public extension PaymentsTransfersFlowWrapperView {
    
    typealias Model = PaymentsTransfersFlow
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias MakeFlowView = (State, @escaping (Event) -> Void) -> FlowView
}
