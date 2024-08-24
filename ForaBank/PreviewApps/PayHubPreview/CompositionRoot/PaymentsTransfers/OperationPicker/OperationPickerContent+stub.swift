//
//  OperationPickerContent+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension OperationPickerContent {
    
    static func stub(
        prefix: [OperationPickerState.Item] = [
            .element(.init(.templates)),
            .element(.init(.exchange))
        ],
        suffix: [OperationPickerState.Item] = [],
        loadResult: [OperationPickerItem<Latest>],
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> OperationPickerContent {
        
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
