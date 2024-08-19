//
//  PayHubContent+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation

extension PayHubContent {
    
    static func stub(
        initialState: PayHubState = .init(loadState: .placeholders([])),
        loadResult: PayHubEffectHandler.MicroServices.LoadResult,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubContent {
        
        let reducer = PayHubReducer(makePlaceholders: {[
            .init(), .init(), .init(), .init()
        ]})
        let effectHandler = PayHubEffectHandler(
            microServices: .init(
                load: { completion in
                    
                    scheduler.schedule(
                        after: .init(.now().advanced(by: .seconds(2)))
                    ) {
                        completion(loadResult)
                    }
                }
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
