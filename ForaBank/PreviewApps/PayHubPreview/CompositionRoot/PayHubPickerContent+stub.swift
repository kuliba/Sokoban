//
//  PayHubPickerContent+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension PayHubPickerContent {
    
    static func stub(
        prefix: [PayHubPickerState.Item] = [
            .element(.init(.templates)),
            .element(.init(.exchange))
        ],
        suffix: [PayHubPickerState.Item] = [],
        loadResult: [OperationPickerItem<Latest>],
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubPickerContent {
        
        let composer = LoadablePickerModelComposer(
            load: { completion in
                
                scheduler.schedule(
                    after: .init(.now().advanced(by: .seconds(2)))
                ) {
                    completion(loadResult)
                }
            },
            scheduler: scheduler
        )
        
        return composer.compose(
            prefix: prefix,
            suffix: suffix,
            placeholderCount: 4
        )
    }
}
