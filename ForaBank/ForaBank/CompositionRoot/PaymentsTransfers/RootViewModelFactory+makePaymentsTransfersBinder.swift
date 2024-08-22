//
//  RootViewModelFactory+makePaymentsTransfersBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    typealias LoadLatestOperationsCompletion = ([Latest]) -> Void
    typealias LoadLatestOperations = (@escaping LoadLatestOperationsCompletion) -> Void
    
    static func makePaymentsTransfersBinder(
        loadLatestOperations: @escaping LoadLatestOperations,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsTransfersBinder {
        
        let pickerContentComposer = LoadablePickerModelComposer<UUID, OperationPickerItem<Latest>>(
            load: { completion in
                
                loadLatestOperations {
                    
                    completion($0.map { .latest($0) })
                }
            },
            scheduler: scheduler
        )
        let pickerBinderComposer = OperationPickerBinderComposer(
            makeContent: {
                
                pickerContentComposer.compose(
                    prefix: [
                        .element(.init(.templates)),
                        .element(.init(.exchange))
                    ],
                    suffix: [],
                    placeholderCount: 4
                )
            },
            scheduler: scheduler
        )
        let composer = PaymentsTransfersBinderComposer(
            makePayHubPickerBinder: pickerBinderComposer.compose
        )
        
        return composer.compose()
    }
}
