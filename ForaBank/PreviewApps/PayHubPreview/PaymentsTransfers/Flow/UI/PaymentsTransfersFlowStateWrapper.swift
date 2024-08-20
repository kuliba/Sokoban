//
//  PaymentsTransfersFlowStateWrapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct PaymentsTransfersFlowStateWrapper<FlowView: View>: View {
    
    @StateObject private var model: Model
    
    private let makeFlowView: MakeFlowView
    
    init(
        model: Model,
        makeFlowView: @escaping MakeFlowView
    ) {
        self._model = .init(wrappedValue: model)
        self.makeFlowView = makeFlowView
    }
    
    var body: some View {
        
        makeFlowView(model.state, model.event(_:))
    }
}

extension PaymentsTransfersFlowStateWrapper {
    
    typealias Model = PaymentsTransfersFlowModel
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias MakeFlowView = (State, @escaping (Event) -> Void) -> FlowView

}
