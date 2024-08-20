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
    
    typealias Binder = PaymentsTransfersBinder<PayHubPickerBinder>
 
    func compose(
        loadResult: Result<[PayHubPickerItem<Latest>], Error>
    ) -> Binder {
        
        let contentComposer = PaymentsTransfersModelComposer()
        let flowComposer = PaymentsTransfersFlowModelComposer(
            scheduler: scheduler
        )
        
        return .init(
            content: contentComposer.compose(loadResult: loadResult),
            flow: flowComposer.compose()
        )
    }
}
