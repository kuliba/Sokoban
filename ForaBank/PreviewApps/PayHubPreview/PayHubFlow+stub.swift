//
//  PayHubFlow+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation

extension PayHubFlow {
    
    static func stub(
        initialState: PayHubFlowState = .init(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubFlow {
        
        let reducer = PayHubFlowReducer()
        let effectHandler = PayHubFlowEffectHandler(
            microServices: .init(
                makeExchange: Exchange.init,
                makeLatestFlow: LatestFlow.init,
                makeTemplates: Templates.init
            )
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
