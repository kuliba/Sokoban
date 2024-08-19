//
//  PaymentsTransfersFlowStateWrapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct PaymentsTransfersFlowStateWrapper<Content: View>: View {
    
    @StateObject private var model: Model
    
    private let makeContent: MakeContent
    
    init(
        model: Model,
        makeContent: @escaping MakeContent
    ) {
        self._model = .init(wrappedValue: model)
        self.makeContent = makeContent
    }
    
    var body: some View {
        
        makeContent(model.state, model.event(_:))
    }
}

extension PaymentsTransfersFlowStateWrapper {
    
    typealias Model = PaymentsTransfersFlowModel
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias MakeContent = (State, @escaping (Event) -> Void) -> Content

}
