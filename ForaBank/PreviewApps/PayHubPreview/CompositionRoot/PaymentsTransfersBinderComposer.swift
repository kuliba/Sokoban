//
//  PaymentsTransfersBinderComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

final class PaymentsTransfersBinderComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension PaymentsTransfersBinderComposer {
    
    typealias Binder = PaymentsTransfersBinder
    
    func compose(
        loadedCategories: [ServiceCategory],
        loadedItems: [PayHubPickerItem<Latest>]
    ) -> Binder {
        
        let contentComposer = PaymentsTransfersModelComposer(
            scheduler: scheduler
        )
        let flowComposer = PaymentsTransfersFlowModelComposer(
            scheduler: scheduler
        )
        
        return .init(
            content: contentComposer.compose(
                loadedCategories: loadedCategories,
                loadedItems: loadedItems
            ),
            flow: flowComposer.compose()
        )
    }
}
