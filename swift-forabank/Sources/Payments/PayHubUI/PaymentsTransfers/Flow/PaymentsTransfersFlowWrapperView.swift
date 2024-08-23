//
//  PaymentsTransfersFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersFlowWrapperView<FlowView, ProfileModel, QRModel>: View
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
    
    typealias Model = PaymentsTransfersFlow<ProfileModel, QRModel>
    typealias State = PaymentsTransfersFlowState<ProfileModel, QRModel>
    typealias Event = PaymentsTransfersFlowEvent<ProfileModel, QRModel>
    typealias MakeFlowView = (State, @escaping (Event) -> Void) -> FlowView
}
