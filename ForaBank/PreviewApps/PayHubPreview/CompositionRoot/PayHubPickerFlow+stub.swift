//
//  PayHubPickerFlow+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation

extension PayHubPickerFlow {
    
    static func stub(
        initialState: PayHubPickerFlowState = .init(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubPickerFlow {
        
        let reducer = PayHubPickerFlowReducer()
        let effectHandler = PayHubPickerFlowEffectHandler(
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
