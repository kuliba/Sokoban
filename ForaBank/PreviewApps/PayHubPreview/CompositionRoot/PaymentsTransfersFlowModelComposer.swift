//
//  PaymentsTransfersFlowModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

final class PaymentsTransfersFlowModelComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension PaymentsTransfersFlowModelComposer {
    
    func compose() -> PaymentsTransfersFlow {
        
        let reducer = PaymentsTransfersFlowReducer()
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            microServices: .init()
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
