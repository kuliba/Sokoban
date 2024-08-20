//
//  PayHubPickerContent+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

extension PayHubPickerContent {
    
    static func stub(
        initialState: PayHubPickerState = .init(
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ],
            suffix: []
        ),
        loadResult: [PayHubPickerItem<Latest>],
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubPickerContent {
        
        let reducer = PayHubPickerReducer(
            makeID: UUID.init,
            makePlaceholders: {
                [.init(), .init(), .init(), .init()]
            }
        )
        let effectHandler = PayHubPickerEffectHandler(
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
