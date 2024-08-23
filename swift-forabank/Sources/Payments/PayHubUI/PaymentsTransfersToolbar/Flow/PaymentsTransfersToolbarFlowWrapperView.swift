//
//  PaymentsTransfersToolbarFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersToolbarFlowWrapperView<FlowView, Profile, QR>: View
where FlowView: View {
    
    @ObservedObject private var model: Model
    
    private let makeFlowView: MakeFlowView
    
    public init(
        model: Model,
        makeFlowView: @escaping MakeFlowView
    ) {
        self.model = model
        self.makeFlowView = makeFlowView
    }
    
    public var body: some View {
        
        makeFlowView(model.state, model.event(_:))
    }
}

public extension PaymentsTransfersToolbarFlowWrapperView {
    
    typealias Model = PaymentsTransfersToolbarFlow<Profile, QR>
    typealias State = PaymentsTransfersToolbarFlowState<Profile, QR>
    typealias Event = PaymentsTransfersToolbarFlowEvent<Profile, QR>
    typealias MakeFlowView = (State, @escaping (Event) -> Void) -> FlowView
}
